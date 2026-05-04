---
title: "[PostgreSQL] 12. 성능 튜닝 (Performance Tuning)"
categories: 
    - postgresql
tags: 
    [postgresql, postgres, postgresql강좌, 고급, 'lecture-postgresql']
toc : true
toc_sticky  : true    
---

PostgreSQL의 성능 분석, 쿼리 최적화, VACUUM, 서버 튜닝 기법을 정리합니다.

# 성능 튜닝 3대 영역

| 영역 | 설명 | 효과 |
|------|------|------|
| 쿼리 최적화 | SQL 문 자체를 개선 | 가장 큰 효과 (80%) |
| VACUUM / 통계 | 죽은 튜플 정리, 통계 갱신 | 높은 효과 |
| 서버 설정 튜닝 | postgresql.conf 파라미터 조정 | 보조적 효과 |

---

## VACUUM (PostgreSQL 핵심 유지보수)

PostgreSQL의 MVCC는 UPDATE/DELETE 시 기존 행을 즉시 삭제하지 않고 죽은 튜플(dead tuple)로 남깁니다.    
VACUUM은 이 죽은 튜플을 정리하는 필수 작업입니다.

### VACUUM 종류

| 종류 | 설명 | 락 |
|------|------|-----|
| VACUUM | 죽은 튜플 정리, 공간 재사용 표시 | 읽기/쓰기 가능 |
| VACUUM FULL | 테이블 재작성, 물리적 공간 반환 | 배타 락 (서비스 중단) |
| VACUUM ANALYZE | VACUUM + 통계 갱신 | 읽기/쓰기 가능 |
| ANALYZE | 통계 정보만 갱신 | 읽기/쓰기 가능 |

```sql
-- 기본 VACUUM
VACUUM employees;

-- VACUUM + 통계 갱신 (권장)
VACUUM ANALYZE employees;

-- VACUUM FULL (공간 반환, 주의: 배타 락)
VACUUM FULL employees;

-- 통계만 갱신
ANALYZE employees;

-- 전체 데이터베이스
VACUUM ANALYZE;
```

### 테이블 부풀림(Bloat) 확인
```sql
-- 죽은 튜플 수 확인
SELECT relname, n_live_tup, n_dead_tup,
    ROUND(n_dead_tup::NUMERIC / NULLIF(n_live_tup, 0) * 100, 1) AS dead_pct
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;

-- 테이블 크기
SELECT pg_size_pretty(pg_total_relation_size('employees')) AS total_size,
    pg_size_pretty(pg_relation_size('employees')) AS table_size,
    pg_size_pretty(pg_indexes_size('employees')) AS index_size;
```

### Autovacuum 설정 (postgresql.conf)
```ini
autovacuum = on                          # 기본 활성화
autovacuum_vacuum_threshold = 50         # 최소 변경 행 수
autovacuum_vacuum_scale_factor = 0.2     # 테이블의 20% 변경 시 실행
autovacuum_analyze_threshold = 50
autovacuum_analyze_scale_factor = 0.1    # 테이블의 10% 변경 시 통계 갱신
autovacuum_max_workers = 3               # 동시 autovacuum 워커 수
```

```sql
-- 테이블별 autovacuum 설정 (대용량 테이블)
ALTER TABLE large_table SET (
    autovacuum_vacuum_scale_factor = 0.01,
    autovacuum_analyze_scale_factor = 0.005
);

-- autovacuum 실행 이력
SELECT relname, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze
FROM pg_stat_user_tables
ORDER BY last_autovacuum DESC NULLS LAST;
```

---

## EXPLAIN 심화 분석

```sql
-- 실제 실행 + 버퍼 통계
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT e.name, d.name
FROM employees e
JOIN departments d ON e.dept_id = d.id
WHERE e.salary > 5000000;
```

### 주요 확인 항목

| 항목 | 설명 | 좋은 값 |
|------|------|--------|
| Seq Scan | 전체 스캔 | 대용량 시 나쁨 |
| Index Scan | 인덱스 사용 | 좋음 |
| Rows Removed by Filter | 필터로 제거된 행 | 적을수록 좋음 |
| Buffers: shared hit | 캐시 히트 | 높을수록 좋음 |
| Buffers: shared read | 디스크 읽기 | 낮을수록 좋음 |

---

## 쿼리 최적화 기법

### 1. 불필요한 Seq Scan 제거
```sql
-- ❌ 컬럼에 함수 적용
SELECT * FROM employees WHERE UPPER(name) = '홍길동';
-- ✅ 표현식 인덱스
CREATE INDEX idx_upper_name ON employees (UPPER(name));

-- ❌ 묵시적 타입 변환
SELECT * FROM employees WHERE id = '1';
-- ✅ 올바른 타입
SELECT * FROM employees WHERE id = 1;
```

### 2. EXISTS vs IN
```sql
-- 서브쿼리 결과가 많을 때: EXISTS
SELECT * FROM departments d
WHERE EXISTS (SELECT 1 FROM employees e WHERE e.dept_id = d.id);

-- 서브쿼리 결과가 적을 때: IN
SELECT * FROM employees WHERE dept_id IN (SELECT id FROM departments WHERE name LIKE '개발%');
```

### 3. 대량 데이터 처리
```sql
-- ❌ 한 번에 대량 UPDATE
UPDATE orders SET status = 'archived' WHERE created_at < NOW() - INTERVAL '1 year';

-- ✅ 배치 처리 (CTE 활용)
WITH batch AS (
    SELECT id FROM orders
    WHERE created_at < NOW() - INTERVAL '1 year' AND status != 'archived'
    LIMIT 10000
)
UPDATE orders SET status = 'archived'
WHERE id IN (SELECT id FROM batch);
-- 영향받은 행이 0이 될 때까지 반복

-- COPY: 대량 데이터 로딩 (INSERT보다 훨씬 빠름)
COPY employees (name, dept, salary) FROM '/path/to/data.csv' WITH CSV HEADER;
```

---

## pg_stat_statements (쿼리 통계)

슬로우 쿼리를 찾는 가장 효과적인 도구입니다.

```sql
-- 확장 설치
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
-- postgresql.conf: shared_preload_libraries = 'pg_stat_statements'

-- 실행 시간이 긴 쿼리 상위 10개
SELECT
    calls,
    ROUND(total_exec_time::NUMERIC, 2) AS total_ms,
    ROUND(mean_exec_time::NUMERIC, 2) AS avg_ms,
    ROUND((100 * total_exec_time / SUM(total_exec_time) OVER ())::NUMERIC, 2) AS pct,
    LEFT(query, 80) AS query
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

-- 통계 초기화
SELECT pg_stat_statements_reset();
```

---

## 서버 설정 튜닝 (postgresql.conf)

### 메모리 설정
```ini
# 공유 버퍼: 전체 메모리의 25% (가장 중요)
shared_buffers = 4GB

# 작업 메모리 (정렬, 해시 조인 등, 세션당)
work_mem = 64MB

# 유지보수 작업 메모리 (VACUUM, CREATE INDEX 등)
maintenance_work_mem = 512MB

# 유효 캐시 크기 (OS 캐시 포함, 전체 메모리의 50~75%)
effective_cache_size = 12GB
```

### WAL 설정
```ini
wal_buffers = 64MB
checkpoint_completion_target = 0.9
max_wal_size = 2GB
min_wal_size = 1GB
```

### 동시성 설정
```ini
max_connections = 200
```

### 현재 설정 확인 및 변경
```sql
-- 현재 값 확인
SHOW shared_buffers;
SHOW work_mem;
SHOW ALL;

-- 세션 수준 변경
SET work_mem = '128MB';

-- 서버 수준 변경 (재시작 필요 여부에 따라)
ALTER SYSTEM SET work_mem = '64MB';
SELECT pg_reload_conf();  -- 리로드로 적용 가능한 설정

-- 재시작 필요 여부 확인
SELECT name, setting, context FROM pg_settings WHERE name = 'shared_buffers';
-- context = 'postmaster'이면 재시작 필요
```

---

## 모니터링 쿼리

### 현재 활성 쿼리
```sql
SELECT pid, usename, state, query_start,
    NOW() - query_start AS duration,
    LEFT(query, 80) AS query
FROM pg_stat_activity
WHERE state = 'active' AND pid != pg_backend_pid()
ORDER BY duration DESC;
```

### 캐시 히트율
```sql
SELECT
    ROUND(100.0 * sum(blks_hit) / sum(blks_hit + blks_read), 2) AS cache_hit_ratio
FROM pg_stat_database;
-- 99% 이상이 정상
```

### 테이블/인덱스 크기
```sql
SELECT
    relname AS table_name,
    pg_size_pretty(pg_total_relation_size(relid)) AS total,
    pg_size_pretty(pg_relation_size(relid)) AS table,
    pg_size_pretty(pg_indexes_size(relid)) AS indexes,
    n_live_tup AS rows
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 10;
```

### 사용되지 않는 인덱스
```sql
SELECT indexrelname, idx_scan, pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;
```

---

## 튜닝 체크리스트

| 단계 | 점검 항목 | 확인 방법 |
|------|----------|----------|
| 1 | pg_stat_statements 활성화 | 슬로우 쿼리 식별 |
| 2 | EXPLAIN ANALYZE 분석 | Seq Scan, 필터 행 수 확인 |
| 3 | 인덱스 누락 확인 | Seq Scan인 대용량 테이블 |
| 4 | 불필요한 인덱스 제거 | idx_scan = 0인 인덱스 |
| 5 | VACUUM/ANALYZE 상태 | dead tuple 비율 확인 |
| 6 | 캐시 히트율 | 99% 이상 유지 |
| 7 | shared_buffers 확인 | 전체 메모리의 25% |
| 8 | work_mem 확인 | 정렬/해시 디스크 사용 여부 |
| 9 | 커넥션 수 확인 | max_connections 대비 사용량 |
| 10 | 테이블 부풀림 확인 | VACUUM FULL 또는 pg_repack |

{% assign c-category = 'postgresql' %}
{% assign c-tag = 'lecture-postgresql' %}
{% include /custom-ref.html %}

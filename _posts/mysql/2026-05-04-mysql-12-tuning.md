---
title: "[MySQL] 12. 성능 튜닝 (Performance Tuning)"
categories: 
    - mysql
tags: 
    [mysql, mariadb, mysql강좌, 고급, 'lecture-mysql']
toc : true
toc_sticky  : true    
---

MySQL/MariaDB의 성능 분석, 쿼리 최적화, 서버 튜닝 기법을 정리합니다.

# 성능 튜닝 3대 영역

| 영역 | 설명 | 효과 |
|------|------|------|
| 쿼리 최적화 | SQL 문 자체를 개선 | 가장 큰 효과 (80%) |
| 인덱스 최적화 | 적절한 인덱스 설계 | 높은 효과 |
| 서버 설정 튜닝 | my.cnf 파라미터 조정 | 보조적 효과 |

---

## 슬로우 쿼리 로그 (Slow Query Log)

실행 시간이 긴 쿼리를 자동으로 기록합니다.

### 설정
```ini
# my.cnf (my.ini)
[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow-query.log
long_query_time = 1          # 1초 이상 걸리는 쿼리 기록
log_queries_not_using_indexes = 1  # 인덱스 미사용 쿼리도 기록
```

```sql
-- 동적 설정 (재시작 없이)
SET GLOBAL slow_query_log = 1;
SET GLOBAL long_query_time = 1;
SET GLOBAL log_queries_not_using_indexes = 1;

-- 현재 설정 확인
SHOW VARIABLES LIKE 'slow_query%';
SHOW VARIABLES LIKE 'long_query_time';
```

### 슬로우 쿼리 분석 도구
```bash
# mysqldumpslow: 슬로우 쿼리 요약
mysqldumpslow -s t -t 10 /var/log/mysql/slow-query.log
# -s t: 실행 시간 순 정렬
# -t 10: 상위 10개

# pt-query-digest (Percona Toolkit): 더 상세한 분석
pt-query-digest /var/log/mysql/slow-query.log
```

---

## EXPLAIN 심화 분석

### EXPLAIN ANALYZE (MySQL 8.0.18+)
실제 실행 시간과 행 수를 포함한 상세 분석을 제공합니다.
```sql
EXPLAIN ANALYZE
SELECT e.name, d.name AS dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.id
WHERE e.salary > 5000000;
```

### 실행 계획 개선 패턴

#### 패턴 1: Full Table Scan → Index Scan
```sql
-- ❌ type: ALL (Full Table Scan)
EXPLAIN SELECT * FROM orders WHERE customer_name = '홍길동';

-- ✅ 인덱스 추가 후 type: ref
CREATE INDEX idx_customer_name ON orders (customer_name);
EXPLAIN SELECT * FROM orders WHERE customer_name = '홍길동';
```

#### 패턴 2: filesort 제거
```sql
-- ❌ Extra: Using filesort
EXPLAIN SELECT * FROM orders WHERE status = 'pending' ORDER BY created_at;

-- ✅ 복합 인덱스로 filesort 제거
CREATE INDEX idx_status_created ON orders (status, created_at);
```

#### 패턴 3: Using temporary 제거
```sql
-- ❌ Extra: Using temporary
EXPLAIN SELECT dept_id, COUNT(*) FROM employees GROUP BY dept_id ORDER BY COUNT(*) DESC;

-- ✅ 인덱스 활용
CREATE INDEX idx_dept ON employees (dept_id);
```

---

## 쿼리 최적화 기법

### 1. SELECT 최적화
```sql
-- ❌ 불필요한 전체 컬럼 조회
SELECT * FROM employees WHERE dept_id = 1;

-- ✅ 필요한 컬럼만 조회
SELECT id, name, salary FROM employees WHERE dept_id = 1;

-- ❌ 서브쿼리 (비효율적인 경우)
SELECT * FROM employees
WHERE dept_id IN (SELECT id FROM departments WHERE name = '개발팀');

-- ✅ JOIN으로 변환
SELECT e.* FROM employees e
INNER JOIN departments d ON e.dept_id = d.id
WHERE d.name = '개발팀';
```

### 2. WHERE 절 최적화
```sql
-- ❌ 컬럼에 함수 적용 (인덱스 무효화)
SELECT * FROM orders WHERE DATE(created_at) = '2026-05-04';
SELECT * FROM employees WHERE LOWER(name) = '홍길동';
SELECT * FROM orders WHERE amount + 100 > 5000;

-- ✅ 값 쪽에 연산 적용
SELECT * FROM orders WHERE created_at >= '2026-05-04' AND created_at < '2026-05-05';
SELECT * FROM employees WHERE name = '홍길동';
SELECT * FROM orders WHERE amount > 4900;
```

### 3. JOIN 최적화
```sql
-- 작은 테이블을 드라이빙 테이블로 (옵티마이저가 자동 판단하지만 힌트 가능)
SELECT /*+ JOIN_ORDER(d, e) */ e.name, d.name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.id;

-- JOIN 컬럼에 인덱스 필수
-- employees.dept_id에 인덱스가 없으면 Nested Loop 시 매번 Full Scan
CREATE INDEX idx_dept_id ON employees (dept_id);
```

### 4. LIMIT 활용
```sql
-- ❌ 전체 조회 후 애플리케이션에서 제한
SELECT * FROM logs ORDER BY created_at DESC;

-- ✅ DB 레벨에서 제한
SELECT * FROM logs ORDER BY created_at DESC LIMIT 100;

-- EXISTS로 존재 여부만 확인
-- ❌
SELECT COUNT(*) FROM orders WHERE user_id = 1;  -- 전체 카운트

-- ✅
SELECT EXISTS(SELECT 1 FROM orders WHERE user_id = 1);  -- 1건만 확인
```

### 5. 대량 데이터 처리
```sql
-- ❌ 한 번에 대량 UPDATE
UPDATE orders SET status = 'archived' WHERE created_at < '2025-01-01';

-- ✅ 배치 처리
-- 1000건씩 나누어 처리 (락 경합 감소)
UPDATE orders SET status = 'archived'
WHERE created_at < '2025-01-01' AND status != 'archived'
LIMIT 1000;
-- 영향받은 행이 0이 될 때까지 반복

-- ❌ 한 번에 대량 INSERT
INSERT INTO target SELECT * FROM source;  -- 수백만 건

-- ✅ 배치 INSERT
INSERT INTO target SELECT * FROM source WHERE id BETWEEN 1 AND 10000;
INSERT INTO target SELECT * FROM source WHERE id BETWEEN 10001 AND 20000;
```

---

## 서버 설정 튜닝 (my.cnf)

### InnoDB 핵심 파라미터

```ini
[mysqld]
# === 메모리 설정 ===
# InnoDB 버퍼 풀: 전체 메모리의 60~80% (가장 중요한 설정)
innodb_buffer_pool_size = 4G

# 버퍼 풀 인스턴스 (버퍼 풀 1GB당 1개 권장)
innodb_buffer_pool_instances = 4

# === 로그 설정 ===
# Redo 로그 크기 (쓰기 성능에 영향)
innodb_log_file_size = 1G

# 로그 버퍼 크기
innodb_log_buffer_size = 64M

# === I/O 설정 ===
# I/O 스레드 수
innodb_read_io_threads = 8
innodb_write_io_threads = 8

# I/O 용량 (SSD: 2000~5000, HDD: 200~400)
innodb_io_capacity = 2000
innodb_io_capacity_max = 4000

# === 동시성 설정 ===
# 동시 스레드 수 (0 = 무제한)
innodb_thread_concurrency = 0

# === 플러시 설정 ===
# 트랜잭션 커밋 시 로그 플러시 (1: 안전, 2: 성능)
innodb_flush_log_at_trx_commit = 1

# 플러시 방식 (Linux에서 O_DIRECT 권장)
innodb_flush_method = O_DIRECT
```

### 연결 및 쿼리 설정
```ini
[mysqld]
# 최대 동시 접속 수
max_connections = 500

# 쿼리 타임아웃 (초)
wait_timeout = 600
interactive_timeout = 600

# 임시 테이블 크기
tmp_table_size = 256M
max_heap_table_size = 256M

# 정렬 버퍼
sort_buffer_size = 4M
join_buffer_size = 4M

# 테이블 캐시
table_open_cache = 4000
```

### 현재 설정 확인 및 동적 변경
```sql
-- 현재 값 확인
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SHOW VARIABLES LIKE 'max_connections';

-- 동적 변경 (재시작 없이)
SET GLOBAL max_connections = 500;
SET GLOBAL innodb_buffer_pool_size = 4294967296;  -- 4GB

-- 상태 모니터링
SHOW GLOBAL STATUS LIKE 'Threads_connected';
SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool%';
```

---

## 모니터링 쿼리

### 현재 프로세스 확인
```sql
-- 현재 실행 중인 쿼리
SHOW PROCESSLIST;
SHOW FULL PROCESSLIST;

-- 특정 쿼리 강제 종료
KILL 프로세스ID;
KILL QUERY 프로세스ID;  -- 쿼리만 종료 (연결 유지)
```

### 버퍼 풀 히트율
```sql
SELECT 
    (1 - (
        (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_reads') /
        (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_read_requests')
    )) * 100 AS buffer_pool_hit_rate;
-- 99% 이상이 정상, 95% 미만이면 버퍼 풀 증가 필요
```

### 테이블/인덱스 크기 확인
```sql
-- 테이블별 크기
SELECT 
    table_name,
    ROUND(data_length / 1024 / 1024, 2) AS data_mb,
    ROUND(index_length / 1024 / 1024, 2) AS index_mb,
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS total_mb,
    table_rows
FROM information_schema.tables
WHERE table_schema = 'mydb'
ORDER BY total_mb DESC;
```

### 사용되지 않는 인덱스 확인 (MySQL 8.0+)
```sql
SELECT 
    object_schema, object_name, index_name
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE index_name IS NOT NULL
  AND count_star = 0
  AND object_schema = 'mydb'
ORDER BY object_name;
```

---

## 튜닝 체크리스트

| 단계 | 점검 항목 | 확인 방법 |
|------|----------|----------|
| 1 | 슬로우 쿼리 로그 활성화 | `SHOW VARIABLES LIKE 'slow_query%'` |
| 2 | 상위 슬로우 쿼리 분석 | `mysqldumpslow` 또는 `pt-query-digest` |
| 3 | EXPLAIN으로 실행 계획 확인 | `EXPLAIN SELECT ...` |
| 4 | 인덱스 누락 확인 | type이 ALL인 쿼리 |
| 5 | 불필요한 인덱스 제거 | `performance_schema` 조회 |
| 6 | 버퍼 풀 히트율 확인 | 99% 이상 유지 |
| 7 | 커넥션 수 확인 | `max_connections` 대비 사용량 |
| 8 | 디스크 I/O 확인 | `innodb_io_capacity` 조정 |
| 9 | 테이블 크기 확인 | 대용량 테이블 파티셔닝 검토 |
| 10 | 정기적인 ANALYZE TABLE | 통계 정보 갱신 |

```sql
-- 테이블 통계 갱신
ANALYZE TABLE employees;

-- 테이블 최적화 (단편화 제거)
OPTIMIZE TABLE employees;
```

{% assign c-category = 'mysql' %}
{% assign c-tag = 'lecture-mysql' %}
{% include /custom-ref.html %}

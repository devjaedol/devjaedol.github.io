---
title: "[PostgreSQL] 07. 인덱스 (Index)"
categories: 
    - postgresql
tags: 
    [postgresql, postgres, postgresql강좌, 중급, 'lecture-postgresql']
toc : true
toc_sticky  : true    
---

PostgreSQL 인덱스의 종류, 생성/관리 방법, 실행 계획 분석을 정리합니다.

# 인덱스 종류

PostgreSQL은 다양한 인덱스 타입을 지원합니다.

| 종류 | 설명 | 용도 |
|------|------|------|
| B-Tree | 기본 인덱스, 균형 트리 | 등치/범위 검색 (기본값) |
| Hash | 해시 기반 | 등치(=) 검색만 |
| GiST | 일반화된 검색 트리 | 기하학, 전문 검색, 범위 타입 |
| SP-GiST | 공간 분할 GiST | 비균형 구조 (전화번호, IP 등) |
| GIN | 역인덱스 | JSONB, 배열, 전문 검색 |
| BRIN | 블록 범위 인덱스 | 대용량 순차 데이터 (시계열) |

---

## 인덱스 생성 및 관리

### 생성
```sql
-- B-Tree (기본)
CREATE INDEX idx_emp_name ON employees (name);

-- 유니크 인덱스
CREATE UNIQUE INDEX uk_emp_email ON employees (email);

-- 복합 인덱스
CREATE INDEX idx_emp_dept_sal ON employees (dept_id, salary);

-- 부분 인덱스 (PostgreSQL 전용, 조건부 인덱스)
CREATE INDEX idx_active_emp ON employees (name) WHERE is_active = TRUE;

-- 표현식 인덱스 (함수 기반)
CREATE INDEX idx_emp_lower_name ON employees (LOWER(name));

-- GIN 인덱스 (JSONB용)
CREATE INDEX idx_data_gin ON products USING GIN (metadata);

-- BRIN 인덱스 (시계열 데이터)
CREATE INDEX idx_logs_created ON logs USING BRIN (created_at);

-- CONCURRENTLY: 락 없이 인덱스 생성 (운영 중 사용)
CREATE INDEX CONCURRENTLY idx_emp_dept ON employees (dept_id);

-- 포함 인덱스 (INCLUDE, PostgreSQL 11+)
CREATE INDEX idx_emp_cover ON employees (dept_id) INCLUDE (name, salary);
```

### 조회
```sql
-- 테이블의 인덱스 목록
\di
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'employees';

-- 인덱스 크기
SELECT pg_size_pretty(pg_relation_size('idx_emp_name')) AS index_size;

-- 인덱스 사용 통계
SELECT indexrelname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE relname = 'employees';
```

### 관리
```sql
-- 인덱스 삭제
DROP INDEX idx_emp_name;
DROP INDEX CONCURRENTLY idx_emp_name;  -- 락 없이 삭제

-- 인덱스 재구축
REINDEX INDEX idx_emp_name;
REINDEX TABLE employees;
REINDEX INDEX CONCURRENTLY idx_emp_name;  -- PostgreSQL 12+
```

---

## 실행 계획 (EXPLAIN)

### 기본 사용법
```sql
-- 예상 실행 계획
EXPLAIN SELECT * FROM employees WHERE dept_id = 1;

-- 실제 실행 + 통계
EXPLAIN ANALYZE SELECT * FROM employees WHERE dept_id = 1;

-- 상세 출력 (버퍼, 타이밍 포함)
EXPLAIN (ANALYZE, BUFFERS, TIMING, FORMAT TEXT)
SELECT * FROM employees WHERE dept_id = 1;

-- JSON 형식 출력
EXPLAIN (ANALYZE, FORMAT JSON)
SELECT * FROM employees WHERE dept_id = 1;
```

### 실행 계획 주요 노드

| 노드 | 설명 | 성능 |
|------|------|------|
| Seq Scan | 테이블 전체 순차 스캔 | 나쁨 (대용량 시) |
| Index Scan | 인덱스 스캔 후 테이블 접근 | 좋음 |
| Index Only Scan | 인덱스만으로 처리 (커버링) | 최고 |
| Bitmap Index Scan | 비트맵으로 인덱스 스캔 | 좋음 (다수 행) |
| Nested Loop | 중첩 루프 조인 | 소량에 좋음 |
| Hash Join | 해시 조인 | 대량에 좋음 |
| Merge Join | 정렬 병합 조인 | 정렬된 데이터에 좋음 |
| Sort | 정렬 | 메모리/디스크 사용 |
| Aggregate | 집계 | GROUP BY 등 |

### 실행 계획 읽는 법
```text
EXPLAIN ANALYZE SELECT e.name, d.name FROM employees e JOIN departments d ON e.dept_id = d.id WHERE e.salary > 5000000;

                                                    QUERY PLAN
-------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=0.15..16.54 rows=2 width=64) (actual time=0.025..0.031 rows=2 loops=1)
   ->  Seq Scan on employees e  (cost=0.00..1.06 rows=2 width=36) (actual time=0.012..0.014 rows=2 loops=1)
         Filter: (salary > 5000000)
         Rows Removed by Filter: 3
   ->  Index Scan using departments_pkey on departments d  (cost=0.15..8.17 rows=1 width=36) (actual time=0.005..0.005 rows=1 loops=2)
         Index Cond: (id = e.dept_id)
 Planning Time: 0.150 ms
 Execution Time: 0.055 ms
```

주요 확인 항목:
- `actual time`: 실제 소요 시간 (ms)
- `rows`: 실제 처리 행 수
- `loops`: 반복 횟수
- `Rows Removed by Filter`: 필터로 제거된 행 수

---

## 복합 인덱스와 최좌선 원칙

`INDEX idx_abc (a, b, c)` 인덱스가 있을 때:

| WHERE 조건 | 인덱스 사용 |
|-----------|-----------|
| `WHERE a = 1` | ✅ 사용 |
| `WHERE a = 1 AND b = 2` | ✅ 사용 |
| `WHERE a = 1 AND b = 2 AND c = 3` | ✅ 전체 사용 |
| `WHERE b = 2` | ❌ 미사용 |
| `WHERE a = 1 AND c = 3` | ⚠️ a만 사용 |

---

## 인덱스가 사용되지 않는 경우

```sql
-- ❌ 컬럼에 함수 적용
SELECT * FROM employees WHERE UPPER(name) = '홍길동';
-- ✅ 표현식 인덱스 생성
CREATE INDEX idx_upper_name ON employees (UPPER(name));

-- ❌ 묵시적 타입 변환
SELECT * FROM employees WHERE id = '1';  -- id가 INTEGER인데 문자열
-- ✅ 올바른 타입
SELECT * FROM employees WHERE id = 1;

-- ❌ LIKE 앞쪽 와일드카드
SELECT * FROM employees WHERE name LIKE '%길동';
-- ✅ pg_trgm 확장으로 해결
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_name_trgm ON employees USING GIN (name gin_trgm_ops);

-- ❌ 소량 데이터 (옵티마이저가 Seq Scan 선택)
-- 테이블이 작으면 인덱스보다 Seq Scan이 빠를 수 있음 (정상 동작)
```

---

## 부분 인덱스 활용 (PostgreSQL 전용)

조건을 만족하는 행에만 인덱스를 생성하여 크기와 성능을 최적화합니다.

```sql
-- 활성 사용자만 인덱스
CREATE INDEX idx_active_users ON users (email) WHERE is_active = TRUE;

-- 최근 주문만 인덱스
CREATE INDEX idx_recent_orders ON orders (user_id) WHERE ordered_at > '2026-01-01';

-- NULL이 아닌 값만 인덱스
CREATE INDEX idx_dept_not_null ON employees (dept_id) WHERE dept_id IS NOT NULL;
```

{% assign c-category = 'postgresql' %}
{% assign c-tag = 'lecture-postgresql' %}
{% include /custom-ref.html %}

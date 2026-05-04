---
title: "[Oracle] 07. 인덱스 (Index)"
categories: 
    - oracle
tags: 
    [oracle, oracle강좌, 중급, 'lecture-oracle']
toc : true
toc_sticky  : true    
---

Oracle 인덱스의 종류, 생성/관리 방법, 실행 계획 분석을 정리합니다.

# 인덱스 종류

| 종류 | 설명 | 용도 |
|------|------|------|
| B-Tree Index | 기본 인덱스, 균형 트리 구조 | 일반적인 검색 (기본값) |
| Unique Index | 중복 불가 인덱스 | PK, UK 제약 |
| Composite Index | 복합 인덱스 (다중 컬럼) | 다중 조건 검색 |
| Bitmap Index | 비트맵 기반 인덱스 | 카디널리티 낮은 컬럼 (성별, 상태) |
| Function-Based Index | 함수 기반 인덱스 | 함수/연산 적용 컬럼 검색 |
| Reverse Key Index | 키 값을 역순 저장 | 시퀀스 기반 INSERT 경합 방지 |
| Index-Organized Table (IOT) | 테이블 자체가 인덱스 | PK 기반 조회가 대부분인 경우 |

---

## 인덱스 생성 및 관리

### 생성
```sql
-- 기본 인덱스
CREATE INDEX idx_emp_name ON employees (name);

-- 유니크 인덱스
CREATE UNIQUE INDEX uk_emp_email ON employees (email);

-- 복합 인덱스
CREATE INDEX idx_emp_dept_sal ON employees (dept_id, salary);

-- 비트맵 인덱스 (DW/OLAP 환경에서 사용)
CREATE BITMAP INDEX bix_emp_dept ON employees (dept_id);

-- 함수 기반 인덱스
CREATE INDEX idx_emp_upper_name ON employees (UPPER(name));

-- 역순 키 인덱스
CREATE INDEX idx_emp_id_rev ON employees (id) REVERSE;

-- 테이블스페이스 지정
CREATE INDEX idx_emp_name ON employees (name) TABLESPACE ts_index;
```

### 조회
```sql
-- 현재 사용자의 인덱스 목록
SELECT index_name, table_name, uniqueness, status
FROM user_indexes
WHERE table_name = 'EMPLOYEES';

-- 인덱스 컬럼 정보
SELECT index_name, column_name, column_position
FROM user_ind_columns
WHERE table_name = 'EMPLOYEES'
ORDER BY index_name, column_position;

-- 인덱스 크기 확인
SELECT segment_name, bytes/1024/1024 AS size_mb
FROM user_segments
WHERE segment_type = 'INDEX'
ORDER BY bytes DESC;
```

### 관리
```sql
-- 인덱스 삭제
DROP INDEX idx_emp_name;

-- 인덱스 재구축 (단편화 해소)
ALTER INDEX idx_emp_name REBUILD;
ALTER INDEX idx_emp_name REBUILD ONLINE;  -- 온라인 재구축 (서비스 중단 없이)

-- 인덱스 비활성화 / 활성화
ALTER INDEX idx_emp_name UNUSABLE;
ALTER INDEX idx_emp_name REBUILD;  -- 다시 활성화

-- 인덱스 통계 갱신
ANALYZE INDEX idx_emp_name COMPUTE STATISTICS;
-- 또는
EXEC DBMS_STATS.GATHER_INDEX_STATS('DEVUSER', 'IDX_EMP_NAME');
```

---

## 실행 계획 (EXPLAIN PLAN)

### 실행 계획 확인 방법
```sql
-- 방법 1: EXPLAIN PLAN
EXPLAIN PLAN FOR
SELECT * FROM employees WHERE dept_id = 1 AND salary > 5000000;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 방법 2: AUTOTRACE (SQL*Plus)
SET AUTOTRACE ON
SELECT * FROM employees WHERE dept_id = 1;
SET AUTOTRACE OFF

-- 방법 3: 실제 실행 통계 포함
SELECT /*+ GATHER_PLAN_STATISTICS */ *
FROM employees WHERE dept_id = 1;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
```

### 실행 계획 주요 오퍼레이션

| 오퍼레이션 | 설명 | 성능 |
|-----------|------|------|
| TABLE ACCESS FULL | 테이블 전체 스캔 | 나쁨 (대용량 시) |
| TABLE ACCESS BY INDEX ROWID | 인덱스로 찾은 ROWID로 테이블 접근 | 좋음 |
| INDEX UNIQUE SCAN | PK/UK 인덱스로 1건 조회 | 최고 |
| INDEX RANGE SCAN | 인덱스 범위 스캔 | 좋음 |
| INDEX FULL SCAN | 인덱스 전체 스캔 | 보통 |
| INDEX FAST FULL SCAN | 인덱스 전체를 멀티블록 읽기 | 보통 |
| INDEX SKIP SCAN | 복합 인덱스 선두 컬럼 건너뜀 | 보통 |
| NESTED LOOPS | 중첩 루프 조인 | 소량 데이터에 좋음 |
| HASH JOIN | 해시 조인 | 대량 데이터에 좋음 |
| SORT MERGE JOIN | 정렬 병합 조인 | 정렬된 데이터에 좋음 |

---

## 복합 인덱스와 최좌선 원칙

`INDEX idx_abc (a, b, c)` 인덱스가 있을 때:

| WHERE 조건 | 인덱스 사용 |
|-----------|-----------|
| `WHERE a = 1` | ✅ 사용 |
| `WHERE a = 1 AND b = 2` | ✅ 사용 |
| `WHERE a = 1 AND b = 2 AND c = 3` | ✅ 전체 사용 |
| `WHERE b = 2` | ⚠️ INDEX SKIP SCAN 가능 |
| `WHERE b = 2 AND c = 3` | ⚠️ INDEX SKIP SCAN 가능 |
| `WHERE a = 1 AND c = 3` | ⚠️ a만 사용 |

> Oracle은 INDEX SKIP SCAN을 지원하여 선두 컬럼이 없어도 인덱스를 사용할 수 있지만,    
> 선두 컬럼의 카디널리티가 낮을 때만 효과적입니다.

---

## 인덱스가 사용되지 않는 경우

```sql
-- ❌ 컬럼에 함수 적용
SELECT * FROM employees WHERE UPPER(name) = '홍길동';
-- ✅ 함수 기반 인덱스 생성
CREATE INDEX idx_upper_name ON employees (UPPER(name));
SELECT * FROM employees WHERE UPPER(name) = '홍길동';

-- ❌ 묵시적 타입 변환
SELECT * FROM employees WHERE id = '1';  -- id가 NUMBER인데 문자열 비교
-- ✅ 올바른 타입
SELECT * FROM employees WHERE id = 1;

-- ❌ LIKE 앞쪽 와일드카드
SELECT * FROM employees WHERE name LIKE '%길동';

-- ❌ NOT, != 조건
SELECT * FROM employees WHERE dept_id != 1;

-- ❌ IS NULL (B-Tree 인덱스는 NULL 미저장)
SELECT * FROM employees WHERE dept_id IS NULL;
-- ✅ 함수 기반 인덱스로 해결
CREATE INDEX idx_dept_null ON employees (NVL(dept_id, -1));
SELECT * FROM employees WHERE NVL(dept_id, -1) = -1;
```

---

## 힌트 (Hint)

Oracle은 옵티마이저에게 실행 계획을 제안하는 힌트를 지원합니다.

```sql
-- 인덱스 사용 강제
SELECT /*+ INDEX(e idx_emp_dept_sal) */ *
FROM employees e
WHERE dept_id = 1;

-- Full Table Scan 강제
SELECT /*+ FULL(e) */ *
FROM employees e
WHERE dept_id = 1;

-- 조인 방식 지정
SELECT /*+ USE_NL(e d) */ e.name, d.name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.id;

SELECT /*+ USE_HASH(e d) */ e.name, d.name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.id;

-- 병렬 처리
SELECT /*+ PARALLEL(e, 4) */ * FROM employees e;
```

| 힌트 | 설명 |
|------|------|
| `INDEX(table index_name)` | 특정 인덱스 사용 |
| `FULL(table)` | Full Table Scan |
| `USE_NL(t1 t2)` | Nested Loop Join |
| `USE_HASH(t1 t2)` | Hash Join |
| `LEADING(t1 t2)` | 조인 순서 지정 |
| `PARALLEL(table, n)` | 병렬 처리 |
| `NO_INDEX(table index)` | 특정 인덱스 사용 금지 |
| `FIRST_ROWS(n)` | 처음 n건 빠르게 반환 |
| `ALL_ROWS` | 전체 처리량 최적화 (기본) |

> 힌트는 옵티마이저가 잘못된 실행 계획을 선택할 때 임시 방편으로 사용합니다.    
> 근본적으로는 통계 갱신, 인덱스 재설계가 우선입니다.

{% assign c-category = 'oracle' %}
{% assign c-tag = 'lecture-oracle' %}
{% include /custom-ref.html %}

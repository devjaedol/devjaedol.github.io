---
title: "[Oracle] 12. 성능 튜닝 (Performance Tuning)"
categories: 
    - oracle
tags: 
    [oracle, oracle강좌, 고급, 'lecture-oracle']
toc : true
toc_sticky  : true    
---

Oracle의 성능 분석, 쿼리 최적화, AWR/ASH, 서버 튜닝 기법을 정리합니다.

# 성능 튜닝 3대 영역

| 영역 | 설명 | 효과 |
|------|------|------|
| SQL 튜닝 | SQL 문 자체를 개선 | 가장 큰 효과 (80%) |
| 인스턴스 튜닝 | SGA/PGA 메모리, 파라미터 조정 | 중간 효과 |
| I/O 튜닝 | 디스크 I/O, 테이블스페이스 배치 | 보조적 효과 |

---

## 실행 계획 분석

### EXPLAIN PLAN
```sql
EXPLAIN PLAN FOR
SELECT e.name, d.name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.id
WHERE e.salary > 5000000;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'ALL'));
```

### 실제 실행 통계 확인
```sql
-- GATHER_PLAN_STATISTICS 힌트 사용
SELECT /*+ GATHER_PLAN_STATISTICS */ e.name, d.name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.id
WHERE e.salary > 5000000;

-- 실제 실행 통계 포함 실행 계획
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
```

### 실행 계획 읽는 법

```text
--------------------------------------------------------------
| Id  | Operation                    | Name     | Rows | Cost |
--------------------------------------------------------------
|   0 | SELECT STATEMENT             |          |    3 |    6 |
|   1 |  NESTED LOOPS                |          |    3 |    6 |
|   2 |   TABLE ACCESS FULL          | EMPLOYEES|    3 |    3 |
|*  3 |   TABLE ACCESS BY INDEX ROWID| DEPARTMENTS| 1  |    1 |
|*  4 |    INDEX UNIQUE SCAN         | PK_DEPT  |    1 |    0 |
--------------------------------------------------------------
```

읽는 순서: 안쪽(들여쓰기 깊은 곳)에서 바깥쪽으로, 위에서 아래로 읽습니다.    
위 예시: 4 → 3 → 2 → 1 → 0

---

## SQL 튜닝 기법

### 1. 불필요한 Full Table Scan 제거
```sql
-- ❌ 인덱스 무효화
SELECT * FROM employees WHERE TRUNC(hire_date) = TO_DATE('2024-01-15', 'YYYY-MM-DD');
SELECT * FROM employees WHERE salary + 1000 > 5000000;
SELECT * FROM employees WHERE TO_CHAR(id) = '1';

-- ✅ 인덱스 활용
SELECT * FROM employees WHERE hire_date >= TO_DATE('2024-01-15', 'YYYY-MM-DD')
                          AND hire_date < TO_DATE('2024-01-16', 'YYYY-MM-DD');
SELECT * FROM employees WHERE salary > 4999000;
SELECT * FROM employees WHERE id = 1;
```

### 2. 서브쿼리 → JOIN 변환
```sql
-- ❌ 상관 서브쿼리 (행마다 서브쿼리 실행)
SELECT name, salary,
    (SELECT AVG(salary) FROM employees e2 WHERE e2.dept_id = e1.dept_id) AS dept_avg
FROM employees e1;

-- ✅ JOIN으로 변환
SELECT e.name, e.salary, da.dept_avg
FROM employees e
INNER JOIN (
    SELECT dept_id, AVG(salary) AS dept_avg
    FROM employees GROUP BY dept_id
) da ON e.dept_id = da.dept_id;
```

### 3. EXISTS vs IN
```sql
-- 서브쿼리 결과가 많을 때: EXISTS가 유리
SELECT * FROM departments d
WHERE EXISTS (SELECT 1 FROM employees e WHERE e.dept_id = d.id);

-- 서브쿼리 결과가 적을 때: IN이 유리
SELECT * FROM employees
WHERE dept_id IN (SELECT id FROM departments WHERE name LIKE '개발%');
```

### 4. 페이징 최적화
```sql
-- ❌ 전체 정렬 후 잘라내기
SELECT * FROM (
    SELECT e.*, ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn
    FROM employees e
)
WHERE rn BETWEEN 101 AND 110;

-- ✅ 인덱스를 활용한 페이징 (salary에 인덱스 있을 때)
SELECT /*+ INDEX_DESC(e idx_salary) */ *
FROM employees e
WHERE ROWNUM <= 110
ORDER BY salary DESC
OFFSET 100 ROWS FETCH NEXT 10 ROWS ONLY;
```

### 5. 대량 데이터 처리
```sql
-- ❌ 한 번에 대량 처리
UPDATE orders SET status = 'archived' WHERE order_date < ADD_MONTHS(SYSDATE, -12);

-- ✅ 배치 처리
DECLARE
    v_rows NUMBER;
BEGIN
    LOOP
        UPDATE orders SET status = 'archived'
        WHERE order_date < ADD_MONTHS(SYSDATE, -12)
          AND status != 'archived'
          AND ROWNUM <= 10000;
        
        v_rows := SQL%ROWCOUNT;
        COMMIT;
        EXIT WHEN v_rows = 0;
    END LOOP;
END;
/

-- 병렬 DML
ALTER SESSION ENABLE PARALLEL DML;
UPDATE /*+ PARALLEL(orders, 4) */ orders
SET status = 'archived'
WHERE order_date < ADD_MONTHS(SYSDATE, -12);
COMMIT;
```

---

## AWR (Automatic Workload Repository)

AWR은 Oracle이 자동으로 수집하는 성능 통계 데이터입니다.    
기본적으로 1시간마다 스냅샷을 생성하고 8일간 보관합니다.

```sql
-- AWR 스냅샷 목록
SELECT snap_id, begin_interval_time, end_interval_time
FROM dba_hist_snapshot
ORDER BY snap_id DESC
FETCH FIRST 20 ROWS ONLY;

-- 수동 스냅샷 생성
EXEC DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT;

-- AWR 리포트 생성 (HTML)
@$ORACLE_HOME/rdbms/admin/awrrpt.sql

-- 특정 SQL의 AWR 리포트
@$ORACLE_HOME/rdbms/admin/awrsqrpt.sql
```

### AWR 리포트 주요 확인 항목

| 섹션 | 확인 항목 |
|------|----------|
| Load Profile | 초당 트랜잭션, 초당 물리적 읽기 |
| Top 5 Timed Events | 가장 많은 대기 시간을 차지하는 이벤트 |
| SQL ordered by Elapsed Time | 실행 시간이 긴 SQL |
| SQL ordered by Gets | 논리적 읽기가 많은 SQL |
| SQL ordered by Reads | 물리적 읽기가 많은 SQL |
| Instance Efficiency | 버퍼 캐시 히트율, 라이브러리 캐시 히트율 |

---

## ASH (Active Session History)

현재 활성 세션의 실시간 성능 데이터입니다.

```sql
-- 현재 활성 세션 확인
SELECT 
    s.sid, s.serial#, s.username,
    s.event, s.wait_class,
    s.sql_id, s.status
FROM v$session s
WHERE s.status = 'ACTIVE'
  AND s.type = 'USER';

-- 최근 1시간 동안 가장 많이 실행된 SQL
SELECT sql_id, COUNT(*) AS sample_count,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM v$active_session_history
WHERE sample_time > SYSDATE - 1/24
GROUP BY sql_id
ORDER BY sample_count DESC
FETCH FIRST 10 ROWS ONLY;

-- ASH 리포트 생성
@$ORACLE_HOME/rdbms/admin/ashrpt.sql
```

---

## 통계 정보 관리

옵티마이저가 올바른 실행 계획을 선택하려면 정확한 통계 정보가 필수입니다.

```sql
-- 테이블 통계 수집
EXEC DBMS_STATS.GATHER_TABLE_STATS('DEVUSER', 'EMPLOYEES');

-- 스키마 전체 통계 수집
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('DEVUSER');

-- 데이터베이스 전체 통계 수집
EXEC DBMS_STATS.GATHER_DATABASE_STATS;

-- 통계 확인
SELECT table_name, num_rows, blocks, avg_row_len, last_analyzed
FROM user_tables
WHERE table_name = 'EMPLOYEES';

-- 컬럼 통계 확인
SELECT column_name, num_distinct, num_nulls, density, histogram
FROM user_tab_col_statistics
WHERE table_name = 'EMPLOYEES';

-- 자동 통계 수집 작업 확인
SELECT client_name, status FROM dba_autotask_client;
```

---

## SGA/PGA 튜닝

### 주요 메모리 파라미터

```sql
-- 현재 메모리 설정 확인
SHOW PARAMETER sga;
SHOW PARAMETER pga;
SHOW PARAMETER memory;

-- 자동 메모리 관리 (AMM) - Oracle 11g+
ALTER SYSTEM SET memory_target = 4G SCOPE=SPFILE;
ALTER SYSTEM SET memory_max_target = 4G SCOPE=SPFILE;

-- 자동 공유 메모리 관리 (ASMM)
ALTER SYSTEM SET sga_target = 3G SCOPE=SPFILE;
ALTER SYSTEM SET pga_aggregate_target = 1G SCOPE=SPFILE;
```

#### SGA 구성 요소

| 구성 요소 | 설명 | 확인 |
|----------|------|------|
| Buffer Cache | 데이터 블록 캐시 | `SHOW PARAMETER db_cache_size` |
| Shared Pool | SQL 파싱 결과, 딕셔너리 캐시 | `SHOW PARAMETER shared_pool_size` |
| Large Pool | RMAN, 병렬 처리 | `SHOW PARAMETER large_pool_size` |
| Java Pool | Java 관련 | `SHOW PARAMETER java_pool_size` |
| Redo Log Buffer | 리두 로그 버퍼 | `SHOW PARAMETER log_buffer` |

### 버퍼 캐시 히트율
```sql
SELECT 
    ROUND((1 - (phy.value / (cur.value + con.value))) * 100, 2) AS hit_ratio
FROM v$sysstat phy, v$sysstat cur, v$sysstat con
WHERE phy.name = 'physical reads'
  AND cur.name = 'db block gets'
  AND con.name = 'consistent gets';
-- 99% 이상이 정상
```

---

## 모니터링 쿼리

### 현재 세션/프로세스
```sql
-- 현재 실행 중인 SQL
SELECT s.sid, s.serial#, s.username, s.status,
    s.sql_id, q.sql_text,
    s.last_call_et AS elapsed_sec
FROM v$session s
LEFT JOIN v$sql q ON s.sql_id = q.sql_id
WHERE s.status = 'ACTIVE' AND s.type = 'USER'
ORDER BY s.last_call_et DESC;

-- 세션 강제 종료
ALTER SYSTEM KILL SESSION 'sid,serial#' IMMEDIATE;
```

### 테이블/인덱스 크기
```sql
SELECT segment_name, segment_type,
    ROUND(bytes / 1024 / 1024, 2) AS size_mb
FROM user_segments
ORDER BY bytes DESC;
```

---

## 튜닝 체크리스트

| 단계 | 점검 항목 | 확인 방법 |
|------|----------|----------|
| 1 | AWR 리포트 확인 | Top 5 Wait Events 분석 |
| 2 | 상위 SQL 식별 | SQL ordered by Elapsed Time |
| 3 | 실행 계획 분석 | EXPLAIN PLAN + DBMS_XPLAN |
| 4 | 인덱스 확인 | Full Table Scan 여부 |
| 5 | 통계 정보 갱신 | DBMS_STATS.GATHER_TABLE_STATS |
| 6 | 버퍼 캐시 히트율 | 99% 이상 유지 |
| 7 | 라이브러리 캐시 히트율 | 바인드 변수 사용 여부 |
| 8 | I/O 분포 확인 | 핫 테이블스페이스 분산 |
| 9 | 락/대기 확인 | v$session, v$lock |
| 10 | 세그먼트 관리 | 단편화 확인, SHRINK/MOVE |

```sql
-- 바인드 변수 사용 권장
-- ❌ 리터럴 SQL (매번 하드 파싱)
SELECT * FROM employees WHERE id = 1;
SELECT * FROM employees WHERE id = 2;

-- ✅ 바인드 변수 (소프트 파싱 재사용)
SELECT * FROM employees WHERE id = :id;
```

{% assign c-category = 'oracle' %}
{% assign c-tag = 'lecture-oracle' %}
{% include /custom-ref.html %}

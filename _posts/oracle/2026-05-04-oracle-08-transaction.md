---
title: "[Oracle] 08. 트랜잭션과 락 (Transaction & Lock)"
categories: 
    - oracle
tags: 
    [oracle, oracle강좌, 중급, 'lecture-oracle']
toc : true
toc_sticky  : true    
---

Oracle의 트랜잭션 관리, MVCC, 격리 수준, 락 메커니즘을 정리합니다.

# Oracle 트랜잭션 특징

Oracle은 MySQL과 달리 기본적으로 AUTO COMMIT이 아닙니다.    
DML(INSERT, UPDATE, DELETE) 실행 후 반드시 `COMMIT` 또는 `ROLLBACK`을 해야 합니다.

> DDL(CREATE, ALTER, DROP)은 자동으로 COMMIT됩니다 (암묵적 커밋).

### Oracle vs MySQL 트랜잭션 차이

| 항목 | Oracle | MySQL (InnoDB) |
|------|--------|---------------|
| 기본 모드 | 수동 COMMIT | AUTO COMMIT |
| DDL 트랜잭션 | 암묵적 COMMIT (롤백 불가) | 암묵적 COMMIT |
| 읽기 일관성 | Undo 세그먼트 기반 MVCC | Undo 로그 기반 MVCC |
| 기본 격리 수준 | READ COMMITTED | REPEATABLE READ |
| Snapshot 격리 | SERIALIZABLE로 구현 | REPEATABLE READ로 구현 |

---

## 트랜잭션 명령어

```sql
-- 트랜잭션은 첫 DML 실행 시 자동 시작됨 (별도 BEGIN 불필요)
INSERT INTO employees (id, name, dept, salary)
VALUES (seq_emp.NEXTVAL, '홍길동', '개발팀', 5000000);

-- 변경 확정
COMMIT;

-- 변경 취소
ROLLBACK;

-- 세이브포인트
SAVEPOINT sp1;
UPDATE employees SET salary = 6000000 WHERE id = 1;

SAVEPOINT sp2;
DELETE FROM employees WHERE id = 5;

-- sp2까지만 롤백 (sp1 이후 변경은 유지)
ROLLBACK TO sp2;

-- 전체 롤백
ROLLBACK;
```

---

## MVCC (Multi-Version Concurrency Control)

Oracle은 Undo 세그먼트를 사용하여 읽기 일관성을 보장합니다.    
읽기 작업은 쓰기 작업을 차단하지 않고, 쓰기 작업도 읽기 작업을 차단하지 않습니다.

```text
세션 A: UPDATE employees SET salary = 6000000 WHERE id = 1;  (COMMIT 전)
세션 B: SELECT salary FROM employees WHERE id = 1;
         → 5000000 (Undo 세그먼트에서 변경 전 값을 읽음)

세션 A: COMMIT;
세션 B: SELECT salary FROM employees WHERE id = 1;
         → 6000000 (COMMIT된 값을 읽음)
```

---

## 격리 수준 (Isolation Level)

Oracle은 3가지 격리 수준만 지원합니다.

| 격리 수준 | Dirty Read | Non-Repeatable Read | Phantom Read |
|----------|:----------:|:-------------------:|:------------:|
| READ COMMITTED (기본) | ❌ 방지 | ⭕ 발생 | ⭕ 발생 |
| SERIALIZABLE | ❌ 방지 | ❌ 방지 | ❌ 방지 |
| READ ONLY | ❌ 방지 | ❌ 방지 | ❌ 방지 |

> Oracle은 READ UNCOMMITTED를 지원하지 않습니다 (Dirty Read 원천 차단).    
> REPEATABLE READ도 별도로 없으며, SERIALIZABLE이 그 역할을 합니다.

```sql
-- 세션 격리 수준 변경
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SET TRANSACTION READ ONLY;

-- 현재 격리 수준 확인 (간접적으로)
SELECT SYS_CONTEXT('USERENV', 'SESSION_USER') FROM DUAL;
```

---

## 락 (Lock)

### 락 종류

| 락 종류 | 설명 |
|--------|------|
| Row Lock (TX) | 행 수준 락, DML 시 자동 획득 |
| Table Lock (TM) | 테이블 수준 락, DDL 또는 명시적 LOCK |
| Row Share (RS) | SELECT ... FOR UPDATE 시 테이블에 설정 |
| Row Exclusive (RX) | DML 시 테이블에 설정 |
| Share (S) | 읽기 공유 락 |
| Exclusive (X) | 배타적 락 |

### 명시적 락
```sql
-- 행 수준 락 (SELECT FOR UPDATE)
SELECT * FROM employees WHERE id = 1 FOR UPDATE;
-- 해당 행에 대해 다른 세션의 UPDATE/DELETE를 차단

-- 대기 시간 지정
SELECT * FROM employees WHERE id = 1 FOR UPDATE WAIT 5;  -- 5초 대기
SELECT * FROM employees WHERE id = 1 FOR UPDATE NOWAIT;  -- 즉시 실패

-- 특정 컬럼만 락 (다른 컬럼은 수정 가능)
SELECT * FROM employees WHERE id = 1 FOR UPDATE OF salary;

-- 테이블 락
LOCK TABLE employees IN EXCLUSIVE MODE;
LOCK TABLE employees IN SHARE MODE;
LOCK TABLE employees IN ROW EXCLUSIVE MODE;
```

### 락 확인
```sql
-- 현재 락 대기 상태 확인
SELECT 
    s1.username AS blocking_user,
    s1.sid AS blocking_sid,
    s2.username AS waiting_user,
    s2.sid AS waiting_sid,
    s2.event AS wait_event
FROM v$lock l1
JOIN v$session s1 ON l1.sid = s1.sid
JOIN v$lock l2 ON l1.id1 = l2.id1 AND l1.id2 = l2.id2
JOIN v$session s2 ON l2.sid = s2.sid
WHERE l1.block = 1 AND l2.request > 0;

-- 간단한 락 확인
SELECT * FROM v$locked_object;

-- 락 보유 세션의 SQL 확인
SELECT s.sid, s.serial#, s.username, q.sql_text
FROM v$session s
JOIN v$sql q ON s.sql_id = q.sql_id
WHERE s.sid IN (SELECT sid FROM v$locked_object);
```

---

## 데드락 (Deadlock)

Oracle은 데드락을 자동 감지하고 한쪽 트랜잭션에 ORA-00060 오류를 발생시킵니다.

```text
ORA-00060: deadlock detected while waiting for resource
```

### 데드락 확인
```sql
-- Alert 로그에서 데드락 정보 확인
-- $ORACLE_BASE/diag/rdbms/<db_name>/<instance>/trace/

-- 트레이스 파일에 상세 데드락 그래프가 기록됨
```

### 예방 전략

| 전략 | 설명 |
|------|------|
| 동일한 순서로 접근 | 테이블/행 접근 순서 통일 |
| 트랜잭션 짧게 유지 | COMMIT을 자주 수행 |
| SELECT FOR UPDATE NOWAIT | 대기 없이 즉시 실패 처리 |
| 적절한 인덱스 | 불필요한 행 잠금 방지 |

```sql
-- NOWAIT으로 데드락 방지
BEGIN
    SELECT * FROM employees WHERE id = 1 FOR UPDATE NOWAIT;
    UPDATE employees SET salary = 6000000 WHERE id = 1;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -54 THEN  -- ORA-00054: resource busy
            DBMS_OUTPUT.PUT_LINE('다른 세션이 사용 중입니다. 잠시 후 재시도하세요.');
            ROLLBACK;
        ELSE
            RAISE;
        END IF;
END;
/
```

---

## ORA-01555: Snapshot Too Old

장시간 실행되는 쿼리가 Undo 세그먼트의 데이터를 읽으려 할 때,    
해당 Undo 데이터가 이미 덮어씌워진 경우 발생합니다.

### 해결 방법

| 방법 | 설명 |
|------|------|
| Undo Tablespace 크기 증가 | `ALTER TABLESPACE undotbs1 ADD DATAFILE ...` |
| UNDO_RETENTION 증가 | `ALTER SYSTEM SET undo_retention = 3600` |
| 쿼리 최적화 | 실행 시간 단축 |
| 배치 처리 | 대량 작업을 작은 단위로 분할 |

```sql
-- Undo 설정 확인
SHOW PARAMETER undo;

-- Undo 보존 시간 변경 (초)
ALTER SYSTEM SET undo_retention = 3600;  -- 1시간
```

{% assign c-category = 'oracle' %}
{% assign c-tag = 'lecture-oracle' %}
{% include /custom-ref.html %}

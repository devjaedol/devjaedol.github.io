---
title: "[PostgreSQL] 08. 트랜잭션과 락 (Transaction & Lock)"
categories: 
    - postgresql
tags: 
    [postgresql, postgres, postgresql강좌, 중급, 'lecture-postgresql']
toc : true
toc_sticky  : true    
---

PostgreSQL의 트랜잭션, MVCC, 격리 수준, 락 메커니즘을 정리합니다.

# 트랜잭션 특징

PostgreSQL은 MySQL과 동일하게 기본 AUTO COMMIT입니다.    
하지만 `BEGIN`으로 명시적 트랜잭션을 시작하면 `COMMIT` 또는 `ROLLBACK`이 필요합니다.

## PostgreSQL vs MySQL vs Oracle 트랜잭션 비교

| 항목 | PostgreSQL | MySQL (InnoDB) | Oracle |
|------|-----------|---------------|--------|
| 기본 모드 | AUTO COMMIT | AUTO COMMIT | 수동 COMMIT |
| DDL 트랜잭션 | ✅ 롤백 가능 | ❌ 암묵적 COMMIT | ❌ 암묵적 COMMIT |
| MVCC | 튜플 버전 관리 | Undo 로그 | Undo 세그먼트 |
| 기본 격리 수준 | READ COMMITTED | REPEATABLE READ | READ COMMITTED |

> PostgreSQL의 가장 큰 장점 중 하나: DDL(CREATE TABLE, ALTER TABLE 등)도 트랜잭션으로 롤백할 수 있습니다.

---

## 트랜잭션 명령어

```sql
-- 트랜잭션 시작
BEGIN;
-- 또는
START TRANSACTION;

-- 변경 확정
COMMIT;

-- 변경 취소
ROLLBACK;

-- 세이브포인트
SAVEPOINT sp1;
ROLLBACK TO sp1;
RELEASE SAVEPOINT sp1;
```

### DDL 트랜잭션 예시
```sql
BEGIN;
CREATE TABLE test_table (id SERIAL PRIMARY KEY, name TEXT);
INSERT INTO test_table (name) VALUES ('테스트');
-- 문제 발생 시 테이블 생성까지 롤백 가능
ROLLBACK;
-- test_table이 생성되지 않음
```

---

## MVCC (Multi-Version Concurrency Control)

PostgreSQL은 각 행(튜플)에 버전 정보를 저장하여 읽기 일관성을 보장합니다.

### 튜플 헤더 정보
```sql
-- 숨겨진 시스템 컬럼 확인
SELECT xmin, xmax, ctid, * FROM employees LIMIT 5;
```

| 컬럼 | 설명 |
|------|------|
| xmin | 이 튜플을 생성한 트랜잭션 ID |
| xmax | 이 튜플을 삭제/수정한 트랜잭션 ID (0이면 유효) |
| ctid | 물리적 위치 (페이지, 오프셋) |

> UPDATE 시 PostgreSQL은 기존 행을 삭제 표시하고 새 행을 삽입합니다.    
> 이로 인해 죽은 튜플(dead tuple)이 발생하며, VACUUM으로 정리해야 합니다.

---

## 격리 수준 (Isolation Level)

| 격리 수준 | Dirty Read | Non-Repeatable Read | Phantom Read | Serialization Anomaly |
|----------|:----------:|:-------------------:|:------------:|:---------------------:|
| READ UNCOMMITTED* | ❌ 방지 | ⭕ 발생 | ⭕ 발생 | ⭕ 발생 |
| READ COMMITTED (기본) | ❌ 방지 | ⭕ 발생 | ⭕ 발생 | ⭕ 발생 |
| REPEATABLE READ | ❌ 방지 | ❌ 방지 | ❌ 방지* | ⭕ 발생 |
| SERIALIZABLE | ❌ 방지 | ❌ 방지 | ❌ 방지 | ❌ 방지 |

> *PostgreSQL의 READ UNCOMMITTED는 실제로 READ COMMITTED와 동일하게 동작합니다 (Dirty Read 불가).    
> *REPEATABLE READ에서도 Phantom Read가 방지됩니다 (스냅샷 격리).

```sql
-- 세션 격리 수준 변경
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- 트랜잭션 시작 시 지정
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- 현재 격리 수준 확인
SHOW transaction_isolation;

-- 기본 격리 수준 변경 (postgresql.conf)
-- default_transaction_isolation = 'read committed'
```

---

## 락 (Lock)

### 테이블 수준 락

| 락 모드 | 설명 |
|--------|------|
| ACCESS SHARE | SELECT 시 자동 획득 |
| ROW SHARE | SELECT FOR UPDATE 시 |
| ROW EXCLUSIVE | INSERT/UPDATE/DELETE 시 |
| SHARE | CREATE INDEX (비동시) 시 |
| EXCLUSIVE | 일부 ALTER TABLE 시 |
| ACCESS EXCLUSIVE | DROP TABLE, TRUNCATE 시 |

### 행 수준 락
```sql
-- SELECT FOR UPDATE (배타 락)
SELECT * FROM employees WHERE id = 1 FOR UPDATE;

-- SELECT FOR SHARE (공유 락)
SELECT * FROM employees WHERE id = 1 FOR SHARE;

-- NOWAIT: 락 획득 실패 시 즉시 오류
SELECT * FROM employees WHERE id = 1 FOR UPDATE NOWAIT;

-- SKIP LOCKED: 잠긴 행 건너뛰기 (큐 패턴에 유용)
SELECT * FROM tasks WHERE status = 'pending'
ORDER BY created_at
LIMIT 1
FOR UPDATE SKIP LOCKED;
```

### 락 확인
```sql
-- 현재 락 상태
SELECT pid, relation::regclass, mode, granted
FROM pg_locks
WHERE relation IS NOT NULL
ORDER BY relation;

-- 락 대기 확인
SELECT
    blocked.pid AS blocked_pid,
    blocked_activity.usename AS blocked_user,
    blocking.pid AS blocking_pid,
    blocking_activity.usename AS blocking_user,
    blocked_activity.query AS blocked_query
FROM pg_catalog.pg_locks blocked
JOIN pg_catalog.pg_locks blocking ON blocking.locktype = blocked.locktype
    AND blocking.relation = blocked.relation
    AND blocking.pid != blocked.pid
JOIN pg_stat_activity blocked_activity ON blocked_activity.pid = blocked.pid
JOIN pg_stat_activity blocking_activity ON blocking_activity.pid = blocking.pid
WHERE NOT blocked.granted;
```

---

## 데드락 (Deadlock)

PostgreSQL은 데드락을 자동 감지하고 한쪽 트랜잭션을 중단합니다.

```text
ERROR: deadlock detected
DETAIL: Process 1234 waits for ShareLock on transaction 5678; blocked by process 9012.
```

### 예방 전략

| 전략 | 설명 |
|------|------|
| 동일한 순서로 접근 | 테이블/행 접근 순서 통일 |
| NOWAIT 사용 | 대기 없이 즉시 실패 처리 |
| 짧은 트랜잭션 | 락 보유 시간 최소화 |
| lock_timeout 설정 | `SET lock_timeout = '5s'` |

```sql
-- 데드락 타임아웃 설정
SET deadlock_timeout = '1s';  -- 기본 1초

-- 락 타임아웃 설정
SET lock_timeout = '5s';

-- 데드락 로그 확인
-- postgresql.conf: log_lock_waits = on
```

---

## Advisory Lock (어드바이저리 락, PostgreSQL 전용)

애플리케이션 수준의 락으로, 테이블/행이 아닌 임의의 숫자 키에 대해 락을 걸 수 있습니다.

```sql
-- 세션 수준 락 (세션 종료 시 자동 해제)
SELECT pg_advisory_lock(12345);
-- 작업 수행 ...
SELECT pg_advisory_unlock(12345);

-- 트랜잭션 수준 락 (COMMIT/ROLLBACK 시 자동 해제)
SELECT pg_advisory_xact_lock(12345);

-- 비대기 락 (실패 시 false 반환)
SELECT pg_try_advisory_lock(12345);
```

{% assign c-category = 'postgresql' %}
{% assign c-tag = 'lecture-postgresql' %}
{% include /custom-ref.html %}

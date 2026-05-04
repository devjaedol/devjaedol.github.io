---
title: "[MySQL] 08. 트랜잭션과 락 (Transaction & Lock)"
categories: 
    - mysql
tags: 
    [mysql, mariadb, mysql강좌, 중급, 'lecture-mysql']
toc : true
toc_sticky  : true    
---

트랜잭션의 개념, ACID 속성, 격리 수준, 그리고 락(Lock) 메커니즘을 정리합니다.

# 트랜잭션이란?
트랜잭션(Transaction)은 하나의 논리적 작업 단위를 구성하는 SQL 명령어들의 집합입니다.    
모두 성공하거나, 모두 실패해야 합니다 (All or Nothing).

## 대표적인 예시: 계좌 이체
```sql
-- A 계좌에서 B 계좌로 100만원 이체
START TRANSACTION;

UPDATE accounts SET balance = balance - 1000000 WHERE id = 'A';
UPDATE accounts SET balance = balance + 1000000 WHERE id = 'B';

-- 둘 다 성공하면
COMMIT;

-- 하나라도 실패하면
ROLLBACK;
```

---

## ACID 속성

| 속성 | 영문 | 설명 |
|------|------|------|
| 원자성 | Atomicity | 트랜잭션 내 작업은 모두 성공하거나 모두 실패 |
| 일관성 | Consistency | 트랜잭션 전후로 데이터 무결성이 유지 |
| 격리성 | Isolation | 동시 실행 트랜잭션이 서로 간섭하지 않음 |
| 지속성 | Durability | COMMIT된 데이터는 영구적으로 보존 |

---

## 트랜잭션 명령어

```sql
-- 트랜잭션 시작
START TRANSACTION;
-- 또는
BEGIN;

-- 변경 사항 확정
COMMIT;

-- 변경 사항 취소
ROLLBACK;

-- 세이브포인트 설정
SAVEPOINT sp1;
-- 특정 세이브포인트까지만 롤백
ROLLBACK TO sp1;
-- 세이브포인트 해제
RELEASE SAVEPOINT sp1;
```

### SAVEPOINT 활용 예시
```sql
START TRANSACTION;

INSERT INTO orders (user_id, product, amount) VALUES (1, '노트북', 1500000);
SAVEPOINT after_order;

INSERT INTO payments (order_id, method, amount) VALUES (LAST_INSERT_ID(), '카드', 1500000);
-- 결제 처리 실패 시 주문까지 롤백하지 않고 결제만 롤백
ROLLBACK TO after_order;

-- 주문은 유지하고 다른 결제 방법 시도
INSERT INTO payments (order_id, method, amount) VALUES (LAST_INSERT_ID(), '계좌이체', 1500000);

COMMIT;
```

---

## AUTO COMMIT
MySQL은 기본적으로 AUTO COMMIT이 활성화되어 있습니다.    
각 SQL 문이 자동으로 COMMIT됩니다.

```sql
-- 현재 설정 확인
SELECT @@autocommit;  -- 1: 활성화, 0: 비활성화

-- 비활성화 (수동 트랜잭션 모드)
SET autocommit = 0;

-- 이후 모든 SQL은 명시적 COMMIT/ROLLBACK 필요
UPDATE employees SET salary = 5500000 WHERE id = 1;
COMMIT;  -- 이걸 해야 반영됨
```

---

## 트랜잭션 격리 수준 (Isolation Level)

동시에 여러 트랜잭션이 실행될 때 발생할 수 있는 문제를 제어합니다.

### 동시성 문제 유형

| 문제 | 설명 |
|------|------|
| Dirty Read | 다른 트랜잭션이 COMMIT하지 않은 데이터를 읽음 |
| Non-Repeatable Read | 같은 쿼리를 두 번 실행했을 때 결과가 다름 (UPDATE) |
| Phantom Read | 같은 조건으로 조회했을 때 행이 추가/삭제됨 (INSERT/DELETE) |

### 격리 수준별 비교

| 격리 수준 | Dirty Read | Non-Repeatable Read | Phantom Read | 성능 |
|----------|:----------:|:-------------------:|:------------:|:----:|
| READ UNCOMMITTED | ⭕ 발생 | ⭕ 발생 | ⭕ 발생 | 최고 |
| READ COMMITTED | ❌ 방지 | ⭕ 발생 | ⭕ 발생 | 좋음 |
| REPEATABLE READ (기본) | ❌ 방지 | ❌ 방지 | ⭕ 발생* | 보통 |
| SERIALIZABLE | ❌ 방지 | ❌ 방지 | ❌ 방지 | 최저 |

> *InnoDB의 REPEATABLE READ는 Gap Lock으로 Phantom Read도 대부분 방지합니다.

```sql
-- 현재 격리 수준 확인
SELECT @@transaction_isolation;

-- 세션 단위 변경
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- 글로벌 변경
SET GLOBAL TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

---

## 락 (Lock)

### 락 종류

| 락 종류 | 설명 | 범위 |
|--------|------|------|
| 공유 락 (S Lock) | 읽기 락, 다른 트랜잭션도 읽기 가능 | 행 |
| 배타 락 (X Lock) | 쓰기 락, 다른 트랜잭션 읽기/쓰기 불가 | 행 |
| 인텐션 락 (IS/IX) | 테이블 수준의 의도 표시 | 테이블 |
| 갭 락 (Gap Lock) | 인덱스 레코드 사이의 간격을 잠금 | 범위 |
| 넥스트키 락 | 레코드 락 + 갭 락 | 범위 |

### 명시적 락
```sql
-- 공유 락 (읽기 락)
SELECT * FROM employees WHERE id = 1 FOR SHARE;
-- MySQL 5.7 이하: LOCK IN SHARE MODE

-- 배타 락 (쓰기 락)
SELECT * FROM employees WHERE id = 1 FOR UPDATE;

-- 테이블 락
LOCK TABLES employees READ;   -- 읽기 전용
LOCK TABLES employees WRITE;  -- 읽기/쓰기 독점
UNLOCK TABLES;
```

---

## 데드락 (Deadlock)

두 트랜잭션이 서로가 가진 락을 기다리며 무한 대기하는 상태입니다.

```text
트랜잭션 A: row 1 락 획득 → row 2 락 대기
트랜잭션 B: row 2 락 획득 → row 1 락 대기
→ 서로 영원히 대기 (Deadlock!)
```

InnoDB는 데드락을 자동 감지하고, 비용이 적은 트랜잭션을 롤백합니다.

### 데드락 방지 전략

| 전략 | 설명 |
|------|------|
| 동일한 순서로 접근 | 테이블/행 접근 순서를 통일 |
| 트랜잭션 짧게 유지 | 락 보유 시간 최소화 |
| 적절한 인덱스 사용 | 불필요한 행 잠금 방지 |
| 낮은 격리 수준 사용 | 필요 이상의 격리 수준 지양 |

```sql
-- 최근 데드락 정보 확인
SHOW ENGINE INNODB STATUS;

-- 현재 락 대기 상태 확인
SELECT * FROM information_schema.INNODB_LOCK_WAITS;
-- MySQL 8.0+
SELECT * FROM performance_schema.data_lock_waits;
```

{% assign c-category = 'mysql' %}
{% assign c-tag = 'lecture-mysql' %}
{% include /custom-ref.html %}

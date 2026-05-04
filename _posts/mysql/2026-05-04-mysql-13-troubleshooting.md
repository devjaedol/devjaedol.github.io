---
title: "[MySQL] 13. 자주 발생하는 Troubleshooting"
categories: 
    - mysql
tags: 
    [mysql, mariadb, mysql강좌, 고급, 'lecture-mysql']
toc : true
toc_sticky  : true    
---

MySQL/MariaDB 운영 중 자주 발생하는 문제와 해결 방법을 빈도순으로 정리합니다.

---

# 1. 접속 오류 (Access Denied / Can't Connect)

가장 빈번하게 발생하는 문제입니다.

### 1-1. Access denied for user

```text
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
```

| 원인 | 해결 방법 |
|------|----------|
| 비밀번호 오류 | 비밀번호 재확인, 특수문자는 따옴표로 감싸기 |
| 호스트 불일치 | `'user'@'localhost'`와 `'user'@'%'`는 별개 사용자 |
| 권한 미부여 | `GRANT` 후 `FLUSH PRIVILEGES` 실행 |

```sql
-- 사용자 존재 여부 확인
SELECT user, host FROM mysql.user WHERE user = 'root';

-- 비밀번호 재설정 (접속 가능한 경우)
ALTER USER 'root'@'localhost' IDENTIFIED BY 'NewPassword123!';
FLUSH PRIVILEGES;
```

#### root 비밀번호 분실 시 복구
```bash
# 1. MySQL 서비스 중지
sudo systemctl stop mysql

# 2. 인증 건너뛰기 모드로 시작
sudo mysqld_safe --skip-grant-tables &

# 3. 비밀번호 없이 접속
mysql -u root

# 4. 비밀번호 변경
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'NewPassword123!';

# 5. 서비스 재시작
sudo systemctl restart mysql
```

Windows의 경우:
```bat
:: 1. 서비스 중지
net stop mysql

:: 2. 인증 건너뛰기 모드로 시작
mysqld --skip-grant-tables --shared-memory

:: 3. 새 CMD 창에서 접속 후 비밀번호 변경
mysql -u root
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'NewPassword123!';

:: 4. 서비스 재시작
net start mysql
```

### 1-2. Can't connect to MySQL server

```text
ERROR 2003 (HY000): Can't connect to MySQL server on 'localhost' (10061)
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock'
```

| 원인 | 확인 방법 | 해결 |
|------|----------|------|
| 서비스 미실행 | `systemctl status mysql` | `systemctl start mysql` |
| 포트 충돌 | `netstat -tlnp \| grep 3306` | 포트 변경 또는 충돌 프로세스 종료 |
| bind-address 설정 | `my.cnf`의 `bind-address` 확인 | `0.0.0.0` 또는 특정 IP로 변경 |
| 방화벽 차단 | `iptables -L` 또는 `ufw status` | 3306 포트 허용 |
| 소켓 파일 누락 | 소켓 경로 확인 | `--socket` 옵션으로 경로 지정 |

```ini
# my.cnf - 원격 접속 허용
[mysqld]
bind-address = 0.0.0.0
port = 3306
```

```bash
# 방화벽 허용 (Ubuntu)
sudo ufw allow 3306/tcp

# 방화벽 허용 (CentOS)
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload
```

---

## 2. Too many connections

```text
ERROR 1040 (HY000): Too many connections
```

동시 접속 수가 `max_connections` 설정을 초과했을 때 발생합니다.

### 즉시 대응
```sql
-- 현재 접속 수 확인
SHOW GLOBAL STATUS LIKE 'Threads_connected';
SHOW GLOBAL STATUS LIKE 'Max_used_connections';
SHOW VARIABLES LIKE 'max_connections';

-- 동적으로 증가 (재시작 없이)
SET GLOBAL max_connections = 500;

-- 불필요한 연결 확인 및 종료
SHOW PROCESSLIST;
KILL 프로세스ID;

-- Sleep 상태의 오래된 연결 확인
SELECT id, user, host, db, command, time, state
FROM information_schema.processlist
WHERE command = 'Sleep' AND time > 300
ORDER BY time DESC;
```

### 근본 해결
```ini
# my.cnf
[mysqld]
max_connections = 500
wait_timeout = 300          # 비활성 연결 5분 후 자동 종료
interactive_timeout = 300
```

| 점검 항목 | 설명 |
|----------|------|
| 커넥션 풀 설정 | 애플리케이션의 DB 커넥션 풀 크기 확인 |
| 커넥션 누수 | close() 호출 누락 여부 확인 |
| wait_timeout | 유휴 연결 자동 종료 시간 조정 |

---

## 3. Lock wait timeout exceeded

```text
ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
```

다른 트랜잭션이 보유한 락을 대기하다가 타임아웃이 발생한 경우입니다.

### 원인 파악
```sql
-- 현재 락 대기 상태 확인 (MySQL 8.0+)
SELECT 
    r.trx_id AS waiting_trx_id,
    r.trx_mysql_thread_id AS waiting_thread,
    r.trx_query AS waiting_query,
    b.trx_id AS blocking_trx_id,
    b.trx_mysql_thread_id AS blocking_thread,
    b.trx_query AS blocking_query
FROM performance_schema.data_lock_waits w
INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.BLOCKING_ENGINE_TRANSACTION_ID
INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.REQUESTING_ENGINE_TRANSACTION_ID;

-- MySQL 5.7
SELECT * FROM information_schema.innodb_lock_waits;

-- 장시간 실행 중인 트랜잭션 확인
SELECT trx_id, trx_state, trx_started, trx_mysql_thread_id, trx_query
FROM information_schema.innodb_trx
ORDER BY trx_started;
```

### 해결 방법

| 방법 | 설명 |
|------|------|
| 블로킹 트랜잭션 종료 | `KILL 블로킹_thread_id` |
| 타임아웃 증가 | `SET innodb_lock_wait_timeout = 120` |
| 트랜잭션 짧게 유지 | 불필요한 작업을 트랜잭션 밖으로 이동 |
| 인덱스 추가 | 인덱스 없으면 테이블 락으로 확대됨 |
| 접근 순서 통일 | 데드락 방지를 위해 테이블/행 접근 순서 통일 |

```sql
-- 타임아웃 설정 변경
SET GLOBAL innodb_lock_wait_timeout = 120;  -- 기본 50초 → 120초
```

---

## 4. 데드락 (Deadlock)

```text
ERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction
```

두 트랜잭션이 서로의 락을 기다리며 교착 상태에 빠진 경우입니다.    
InnoDB는 자동으로 감지하고 한쪽을 롤백합니다.

### 원인 분석
```sql
-- 가장 최근 데드락 정보 확인
SHOW ENGINE INNODB STATUS;
-- LATEST DETECTED DEADLOCK 섹션 확인
```

### 해결 및 예방

```sql
-- ❌ 데드락 발생 패턴
-- 트랜잭션 A: UPDATE accounts SET balance = balance - 100 WHERE id = 1;
--             UPDATE accounts SET balance = balance + 100 WHERE id = 2;
-- 트랜잭션 B: UPDATE accounts SET balance = balance - 50 WHERE id = 2;
--             UPDATE accounts SET balance = balance + 50 WHERE id = 1;

-- ✅ 동일한 순서로 접근 (id 오름차순)
-- 트랜잭션 A: UPDATE ... WHERE id = 1; → UPDATE ... WHERE id = 2;
-- 트랜잭션 B: UPDATE ... WHERE id = 1; → UPDATE ... WHERE id = 2;
```

| 예방 전략 | 설명 |
|----------|------|
| 접근 순서 통일 | 항상 같은 순서로 테이블/행에 접근 |
| 트랜잭션 최소화 | 트랜잭션 범위를 최대한 짧게 |
| 적절한 인덱스 | 인덱스 없으면 불필요한 행까지 잠금 |
| 재시도 로직 | 애플리케이션에서 데드락 시 자동 재시도 구현 |

```python
# 애플리케이션 재시도 로직 예시 (Python)
import time

MAX_RETRIES = 3
for attempt in range(MAX_RETRIES):
    try:
        cursor.execute("START TRANSACTION")
        cursor.execute("UPDATE accounts SET balance = balance - 100 WHERE id = 1")
        cursor.execute("UPDATE accounts SET balance = balance + 100 WHERE id = 2")
        cursor.execute("COMMIT")
        break
    except mysql.connector.errors.DatabaseError as e:
        if e.errno == 1213 and attempt < MAX_RETRIES - 1:  # Deadlock
            cursor.execute("ROLLBACK")
            time.sleep(0.1 * (attempt + 1))  # 점진적 대기
        else:
            raise
```

---

## 5. 테이블 깨짐 / 크래시 복구

```text
ERROR 1194 (HY000): Table 'mytable' is marked as crashed and should be repaired
ERROR 145 (HY000): Table './mydb/mytable' is marked as crashed and last (automatic?) repair failed
```

주로 MyISAM 테이블에서 발생합니다. InnoDB는 자동 복구 기능이 있어 상대적으로 드뭅니다.

### MyISAM 테이블 복구
```sql
-- 테이블 상태 확인
CHECK TABLE mytable;

-- 테이블 복구
REPAIR TABLE mytable;

-- 빠른 복구
REPAIR TABLE mytable QUICK;

-- 확장 복구 (시간이 오래 걸림)
REPAIR TABLE mytable EXTENDED;
```

```bash
# 서버 중지 후 myisamchk로 복구
myisamchk -r /var/lib/mysql/mydb/mytable.MYI
```

### InnoDB 크래시 복구
```ini
# my.cnf - 강제 복구 모드 (1~6, 높을수록 강력)
[mysqld]
innodb_force_recovery = 1
```

```bash
# 1. 복구 모드로 시작
# innodb_force_recovery = 1 설정 후 서비스 시작

# 2. 데이터 덤프
mysqldump -u root -p --all-databases > emergency_backup.sql

# 3. 복구 모드 해제 후 재시작
# innodb_force_recovery 주석 처리 후 서비스 재시작

# 4. 필요 시 덤프로 복원
```

| 복구 레벨 | 설명 |
|----------|------|
| 1 (SRV_FORCE_IGNORE_CORRUPT) | 손상된 페이지 무시 |
| 2 (SRV_FORCE_NO_BACKGROUND) | 백그라운드 스레드 중지 |
| 3 (SRV_FORCE_NO_TRX_UNDO) | 트랜잭션 롤백 건너뜀 |
| 4 (SRV_FORCE_NO_IBUF_MERGE) | Insert Buffer 병합 건너뜀 |
| 5 (SRV_FORCE_NO_UNDO_LOG_SCAN) | Undo 로그 스캔 건너뜀 |
| 6 (SRV_FORCE_NO_LOG_REDO) | Redo 로그 적용 건너뜀 |

> ⚠️ 레벨 4 이상은 데이터 손실 가능성이 있습니다. 반드시 백업 후 진행하세요.

---

## 6. 한글 깨짐 (Character Set 문제)

```text
데이터 조회 시 ???, ë¬¸ì, ÃÃÃ 등으로 표시
```

### 현재 설정 확인
```sql
-- 서버 문자셋 확인
SHOW VARIABLES LIKE 'character_set%';
SHOW VARIABLES LIKE 'collation%';

-- 데이터베이스 문자셋 확인
SELECT default_character_set_name, default_collation_name
FROM information_schema.schemata
WHERE schema_name = 'mydb';

-- 테이블/컬럼 문자셋 확인
SELECT column_name, character_set_name, collation_name
FROM information_schema.columns
WHERE table_schema = 'mydb' AND table_name = 'mytable';
```

### 해결 방법

#### 서버 기본 설정 (my.cnf)
```ini
[mysqld]
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[client]
default-character-set = utf8mb4

[mysql]
default-character-set = utf8mb4
```

#### 기존 데이터베이스/테이블 변환
```sql
-- 데이터베이스 문자셋 변경
ALTER DATABASE mydb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 테이블 문자셋 변경
ALTER TABLE mytable CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 접속 시 문자셋 지정
SET NAMES utf8mb4;
```

#### utf8 vs utf8mb4

| 항목 | utf8 (utf8mb3) | utf8mb4 |
|------|---------------|---------|
| 바이트 | 최대 3바이트 | 최대 4바이트 |
| 이모지 지원 | ❌ | ✅ |
| 권장 여부 | 비권장 (레거시) | 권장 |

> 새 프로젝트는 반드시 `utf8mb4`를 사용하세요. `utf8`은 이모지(😀)를 저장할 수 없습니다.

---

## 7. 디스크 용량 부족

```text
ERROR 1114 (HY000): The table 'mytable' is full
ERROR 28: No space left on device
```

### 원인 파악
```sql
-- 데이터베이스별 용량 확인
SELECT 
    table_schema AS db_name,
    ROUND(SUM(data_length + index_length) / 1024 / 1024 / 1024, 2) AS total_gb
FROM information_schema.tables
GROUP BY table_schema
ORDER BY total_gb DESC;

-- 대용량 테이블 확인
SELECT 
    table_name,
    ROUND(data_length / 1024 / 1024, 2) AS data_mb,
    ROUND(index_length / 1024 / 1024, 2) AS index_mb,
    table_rows
FROM information_schema.tables
WHERE table_schema = 'mydb'
ORDER BY (data_length + index_length) DESC
LIMIT 10;
```

### 해결 방법

| 방법 | 명령어 | 설명 |
|------|--------|------|
| 바이너리 로그 정리 | `PURGE BINARY LOGS BEFORE '2026-04-01'` | 오래된 binlog 삭제 |
| 불필요한 데이터 삭제 | `DELETE` + `OPTIMIZE TABLE` | 오래된 로그/이력 데이터 정리 |
| 테이블 최적화 | `OPTIMIZE TABLE mytable` | 단편화 제거, 공간 회수 |
| 임시 파일 정리 | `tmpdir` 경로 확인 | 임시 파일 삭제 |
| 에러 로그 정리 | 로그 파일 로테이션 | 오래된 로그 삭제 |

```sql
-- 바이너리 로그 자동 만료 설정
SET GLOBAL expire_logs_days = 7;
-- MySQL 8.0+
SET GLOBAL binlog_expire_logs_seconds = 604800;  -- 7일

-- 테이블 최적화 (DELETE 후 공간 회수)
OPTIMIZE TABLE large_table;

-- General 로그 비활성화 (용량 절약)
SET GLOBAL general_log = 0;
```

---

## 8. 쿼리 실행이 갑자기 느려짐

갑자기 쿼리 성능이 저하되는 경우의 점검 순서입니다.

### 점검 체크리스트

| 순서 | 점검 항목 | 확인 명령어 |
|:----:|----------|-----------|
| 1 | 현재 실행 중인 쿼리 확인 | `SHOW FULL PROCESSLIST` |
| 2 | 락 대기 여부 | `SELECT * FROM information_schema.innodb_trx` |
| 3 | 서버 부하 확인 | `SHOW GLOBAL STATUS LIKE 'Threads_running'` |
| 4 | 버퍼 풀 히트율 | `SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool%'` |
| 5 | 디스크 I/O | OS 레벨 `iostat`, `iotop` 확인 |
| 6 | 테이블 통계 갱신 | `ANALYZE TABLE 테이블명` |
| 7 | 실행 계획 변경 여부 | `EXPLAIN` 재확인 |

```sql
-- 현재 활성 쿼리 확인
SELECT id, user, host, db, command, time, state, info
FROM information_schema.processlist
WHERE command != 'Sleep'
ORDER BY time DESC;

-- 테이블 통계 갱신 (실행 계획이 갑자기 바뀐 경우)
ANALYZE TABLE employees;

-- 쿼리 캐시 상태 확인 (MySQL 5.7 이하)
SHOW VARIABLES LIKE 'query_cache%';
```

#### 통계 정보 불일치로 인한 성능 저하
대량 INSERT/DELETE 후 통계 정보가 실제 데이터와 맞지 않으면 옵티마이저가 잘못된 실행 계획을 선택합니다.
```sql
-- 해결: 통계 갱신
ANALYZE TABLE mytable;

-- InnoDB 통계 자동 갱신 설정
SET GLOBAL innodb_stats_auto_recalc = 1;  -- 기본값 ON
SET GLOBAL innodb_stats_persistent = 1;
```

---

## 9. Packet too large

```text
ERROR 1153 (08S01): Got a packet bigger than 'max_allowed_packet' bytes
```

대용량 데이터(BLOB, 대량 INSERT 등)를 전송할 때 발생합니다.

```sql
-- 현재 설정 확인
SHOW VARIABLES LIKE 'max_allowed_packet';

-- 동적 변경
SET GLOBAL max_allowed_packet = 256 * 1024 * 1024;  -- 256MB
```

```ini
# my.cnf (영구 설정)
[mysqld]
max_allowed_packet = 256M

[mysqldump]
max_allowed_packet = 256M
```

---

## 10. Duplicate entry (중복 키 오류)

```text
ERROR 1062 (23000): Duplicate entry 'value' for key 'PRIMARY'
ERROR 1062 (23000): Duplicate entry 'user@email.com' for key 'uk_email'
```

### 상황별 해결

```sql
-- 중복 무시하고 삽입
INSERT IGNORE INTO users (email, name) VALUES ('test@test.com', '홍길동');

-- 중복 시 업데이트
INSERT INTO users (email, name, updated_at)
VALUES ('test@test.com', '홍길동', NOW())
ON DUPLICATE KEY UPDATE name = VALUES(name), updated_at = NOW();

-- AUTO_INCREMENT 값 확인 및 리셋
SELECT AUTO_INCREMENT
FROM information_schema.tables
WHERE table_schema = 'mydb' AND table_name = 'users';

-- AUTO_INCREMENT 리셋 (현재 최대값 + 1로)
ALTER TABLE users AUTO_INCREMENT = 1;
```

---

## 11. Foreign Key 제약 오류

```text
ERROR 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails
```

### 해결 방법
```sql
-- 참조하는 자식 데이터 확인
SELECT * FROM orders WHERE user_id = 삭제하려는_ID;

-- 자식 데이터 먼저 삭제 후 부모 삭제
DELETE FROM orders WHERE user_id = 1;
DELETE FROM users WHERE id = 1;

-- 대량 작업 시 일시적으로 FK 체크 비활성화
SET FOREIGN_KEY_CHECKS = 0;
-- 작업 수행 ...
TRUNCATE TABLE orders;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;
```

> ⚠️ `FOREIGN_KEY_CHECKS = 0`은 데이터 무결성을 보장하지 않으므로, 마이그레이션이나 초기 데이터 로딩 시에만 사용하세요.

---

## 12. MySQL 서비스가 자동 종료됨 (OOM Killer)

Linux 환경에서 메모리 부족 시 OS의 OOM Killer가 MySQL 프로세스를 강제 종료합니다.

### 확인
```bash
# OOM Killer 로그 확인
dmesg | grep -i "oom\|killed"
grep -i "oom" /var/log/syslog

# MySQL 에러 로그 확인
tail -100 /var/log/mysql/error.log
```

### 해결

| 방법 | 설명 |
|------|------|
| 버퍼 풀 축소 | `innodb_buffer_pool_size`를 전체 메모리의 50~60%로 |
| 커넥션 수 제한 | `max_connections` 축소 |
| 스왑 설정 | 스왑 공간 확보 |
| OOM 점수 조정 | MySQL 프로세스의 OOM 점수를 낮춤 |

```bash
# MySQL 프로세스의 OOM 점수 낮추기 (종료 우선순위 낮춤)
echo -1000 > /proc/$(pidof mysqld)/oom_score_adj
```

```ini
# my.cnf - 메모리 사용량 줄이기
[mysqld]
innodb_buffer_pool_size = 2G    # 서버 메모리에 맞게 조정
max_connections = 200
tmp_table_size = 64M
max_heap_table_size = 64M
sort_buffer_size = 2M
join_buffer_size = 2M
```

---

## 13. 복제(Replication) 오류

Master-Slave 복제 환경에서 자주 발생하는 문제입니다.

```text
Last_SQL_Error: Could not execute Write_rows event ... Duplicate entry
Last_SQL_Error: Could not execute Delete_rows event ... Can't find record
```

### 복제 상태 확인
```sql
-- Slave에서 실행
SHOW SLAVE STATUS\G

-- 주요 확인 항목
-- Slave_IO_Running: Yes
-- Slave_SQL_Running: Yes
-- Seconds_Behind_Master: 0 (지연 없음)
-- Last_SQL_Error: (오류 메시지)
```

### 해결 방법

```sql
-- 특정 오류 건너뛰기 (1건)
STOP SLAVE;
SET GLOBAL sql_slave_skip_counter = 1;
START SLAVE;

-- 특정 에러 코드 무시 설정 (my.cnf)
-- ⚠️ 데이터 불일치 가능성 있으므로 주의
-- slave-skip-errors = 1062,1032
```

| 상황 | 해결 |
|------|------|
| 일시적 오류 | `sql_slave_skip_counter`로 건너뛰기 |
| 데이터 불일치 | `pt-table-checksum` + `pt-table-sync`로 동기화 |
| 심각한 불일치 | Slave 재구축 (mysqldump로 다시 복제 설정) |
| 지연 (Lag) | 병렬 복제 설정 (`slave_parallel_workers`) |

---

## 트러블슈팅 필수 명령어 요약

```sql
-- 서버 상태 전체 확인
SHOW GLOBAL STATUS;
SHOW GLOBAL VARIABLES;

-- 현재 프로세스
SHOW FULL PROCESSLIST;

-- InnoDB 상태 (락, 데드락, 버퍼 풀 등)
SHOW ENGINE INNODB STATUS;

-- 에러 로그 위치 확인
SHOW VARIABLES LIKE 'log_error';

-- 실행 중인 트랜잭션
SELECT * FROM information_schema.innodb_trx;

-- 테이블 상태 점검
CHECK TABLE mytable;
ANALYZE TABLE mytable;
OPTIMIZE TABLE mytable;
```

{% assign c-category = 'mysql' %}
{% assign c-tag = 'lecture-mysql' %}
{% include /custom-ref.html %}

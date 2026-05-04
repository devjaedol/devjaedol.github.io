---
title: "[Oracle] 13. 자주 발생하는 Troubleshooting"
categories: 
    - oracle
tags: 
    [oracle, oracle강좌, 고급, 'lecture-oracle']
toc : true
toc_sticky  : true    
---

Oracle 운영 중 자주 발생하는 문제와 해결 방법을 빈도순으로 정리합니다.

---

# 1. ORA-12541: TNS:no listener / ORA-12514: TNS:listener does not currently know of service

가장 빈번한 접속 오류입니다.

```text
ORA-12541: TNS:no listener
ORA-12514: TNS:listener does not currently know of service requested in connect descriptor
```

| 원인 | 해결 방법 |
|------|----------|
| 리스너 미실행 | `lsnrctl start` |
| 리스너에 서비스 미등록 | `ALTER SYSTEM REGISTER` |
| tnsnames.ora 설정 오류 | SERVICE_NAME / SID 확인 |
| 포트 불일치 | listener.ora의 포트 확인 (기본 1521) |
| 방화벽 차단 | 1521 포트 허용 |

```bash
# 리스너 상태 확인
lsnrctl status

# 리스너 시작
lsnrctl start

# 리스너에 서비스 강제 등록
sqlplus / as sysdba
ALTER SYSTEM REGISTER;
```

```text
-- tnsnames.ora 확인 ($ORACLE_HOME/network/admin/tnsnames.ora)
XE =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVICE_NAME = XE)
    )
  )
```

---

## 2. ORA-00942: table or view does not exist

```text
ORA-00942: table or view does not exist
```

테이블이 존재하는데도 이 오류가 발생하는 경우가 많습니다.

| 원인 | 해결 방법 |
|------|----------|
| 다른 스키마의 테이블 | `스키마명.테이블명` 으로 접근 |
| 권한 부족 | `GRANT SELECT ON 스키마.테이블 TO 사용자` |
| 대소문자 문제 | Oracle은 기본 대문자, 따옴표로 생성 시 대소문자 구분 |
| 시노님 미설정 | `CREATE SYNONYM` 생성 |

```sql
-- 테이블 존재 확인
SELECT owner, table_name FROM all_tables WHERE table_name = 'EMPLOYEES';

-- 다른 스키마 테이블 접근
SELECT * FROM hr.employees;

-- 시노님 생성 (매번 스키마명 안 붙여도 됨)
CREATE SYNONYM employees FOR hr.employees;

-- 대소문자 주의: 따옴표로 생성한 경우
CREATE TABLE "myTable" (id NUMBER);  -- 소문자로 생성됨
SELECT * FROM "myTable";             -- 따옴표 필수
SELECT * FROM myTable;               -- ORA-00942 발생 (MYTABLE로 변환됨)
```

---

## 3. ORA-01017: invalid username/password; logon denied

```text
ORA-01017: invalid username/password; logon denied
```

| 원인 | 해결 방법 |
|------|----------|
| 비밀번호 오류 | 비밀번호 재확인 (대소문자 구분) |
| 계정 잠금 | `ALTER USER 사용자 ACCOUNT UNLOCK` |
| 비밀번호 만료 | `ALTER USER 사용자 IDENTIFIED BY 새비밀번호` |
| OS 인증 문제 | `sqlplus / as sysdba` 시 OS 그룹 확인 |

```sql
-- 계정 상태 확인
SELECT username, account_status, lock_date, expiry_date
FROM dba_users WHERE username = 'DEVUSER';

-- 계정 잠금 해제 + 비밀번호 변경
ALTER USER devuser ACCOUNT UNLOCK;
ALTER USER devuser IDENTIFIED BY "NewPass123!";
```

---

## 4. ORA-01653 / ORA-01654: unable to extend table/index

```text
ORA-01653: unable to extend table DEVUSER.EMPLOYEES by 1024 in tablespace USERS
```

테이블스페이스의 공간이 부족할 때 발생합니다.

### 해결 방법
```sql
-- 테이블스페이스 사용량 확인
SELECT 
    t.tablespace_name,
    ROUND(t.total_mb, 2) AS total_mb,
    ROUND(t.total_mb - f.free_mb, 2) AS used_mb,
    ROUND(f.free_mb, 2) AS free_mb,
    ROUND((1 - f.free_mb / t.total_mb) * 100, 1) AS used_pct
FROM 
    (SELECT tablespace_name, SUM(bytes)/1024/1024 AS total_mb FROM dba_data_files GROUP BY tablespace_name) t
LEFT JOIN
    (SELECT tablespace_name, SUM(bytes)/1024/1024 AS free_mb FROM dba_free_space GROUP BY tablespace_name) f
ON t.tablespace_name = f.tablespace_name
ORDER BY used_pct DESC;

-- 방법 1: 데이터파일 자동 확장 활성화
ALTER DATABASE DATAFILE '/opt/oracle/oradata/XE/users01.dbf' AUTOEXTEND ON NEXT 100M MAXSIZE 10G;

-- 방법 2: 데이터파일 추가
ALTER TABLESPACE users ADD DATAFILE '/opt/oracle/oradata/XE/users02.dbf' SIZE 1G AUTOEXTEND ON;

-- 방법 3: 데이터파일 크기 수동 확장
ALTER DATABASE DATAFILE '/opt/oracle/oradata/XE/users01.dbf' RESIZE 5G;
```

---

## 5. ORA-01555: snapshot too old

```text
ORA-01555: snapshot too old: rollback segment number ... with name "..." too small
```

장시간 실행되는 쿼리가 Undo 데이터를 읽으려 할 때, 이미 덮어씌워진 경우 발생합니다.

| 원인 | 해결 방법 |
|------|----------|
| Undo Tablespace 부족 | Undo 테이블스페이스 크기 증가 |
| UNDO_RETENTION 짧음 | `ALTER SYSTEM SET undo_retention = 3600` |
| 쿼리 실행 시간이 너무 김 | 쿼리 최적화, 배치 분할 |
| COMMIT이 너무 잦음 | 대량 처리 시 적절한 COMMIT 간격 |

```sql
-- Undo 설정 확인
SHOW PARAMETER undo;

-- Undo 보존 시간 증가
ALTER SYSTEM SET undo_retention = 3600;  -- 1시간

-- Undo Tablespace 크기 확인
SELECT tablespace_name, SUM(bytes)/1024/1024 AS size_mb
FROM dba_data_files WHERE tablespace_name LIKE 'UNDO%'
GROUP BY tablespace_name;

-- Undo Tablespace 확장
ALTER DATABASE DATAFILE '/opt/oracle/oradata/XE/undotbs01.dbf' RESIZE 5G;
```

---

## 6. ORA-04031: unable to allocate shared memory

```text
ORA-04031: unable to allocate ... bytes of shared memory
```

Shared Pool 메모리가 부족할 때 발생합니다.

| 원인 | 해결 방법 |
|------|----------|
| Shared Pool 크기 부족 | `ALTER SYSTEM SET shared_pool_size = 1G` |
| 리터럴 SQL 과다 사용 | 바인드 변수 사용으로 전환 |
| 하드 파싱 과다 | `CURSOR_SHARING = FORCE` (임시 방편) |
| 메모리 단편화 | Shared Pool 플러시 (비상 시) |

```sql
-- Shared Pool 사용량 확인
SELECT pool, name, bytes/1024/1024 AS mb
FROM v$sgastat
WHERE pool = 'shared pool'
ORDER BY bytes DESC;

-- 비상 시 Shared Pool 플러시 (운영 중 주의)
ALTER SYSTEM FLUSH SHARED_POOL;

-- 바인드 변수 강제 (임시 방편, 부작용 가능)
ALTER SYSTEM SET cursor_sharing = FORCE;
```

---

## 7. ORA-00060: deadlock detected

```text
ORA-00060: deadlock detected while waiting for resource
```

두 세션이 서로의 락을 기다리는 교착 상태입니다.

### 원인 분석
```bash
# Alert 로그에서 데드락 트레이스 파일 경로 확인
# $ORACLE_BASE/diag/rdbms/<db>/<instance>/trace/

# 트레이스 파일에 데드락 그래프가 기록됨
```

```sql
-- 현재 락 대기 확인
SELECT 
    s1.username AS blocker, s1.sid AS blocker_sid,
    s2.username AS waiter, s2.sid AS waiter_sid,
    s2.event
FROM v$lock l1
JOIN v$session s1 ON l1.sid = s1.sid
JOIN v$lock l2 ON l1.id1 = l2.id1 AND l1.id2 = l2.id2
JOIN v$session s2 ON l2.sid = s2.sid
WHERE l1.block = 1 AND l2.request > 0;
```

### 예방
- 테이블/행 접근 순서 통일
- `SELECT FOR UPDATE NOWAIT` 사용
- 트랜잭션을 짧게 유지
- 적절한 인덱스 사용

---

## 8. ORA-01000: maximum open cursors exceeded

```text
ORA-01000: maximum open cursors exceeded
```

열린 커서 수가 `OPEN_CURSORS` 설정을 초과했을 때 발생합니다.

| 원인 | 해결 방법 |
|------|----------|
| 커서 닫기 누락 | 애플리케이션에서 커서/Statement close() 확인 |
| OPEN_CURSORS 부족 | `ALTER SYSTEM SET open_cursors = 1000` |
| 커서 누수 | 코드 리뷰로 누수 지점 확인 |

```sql
-- 현재 설정 확인
SHOW PARAMETER open_cursors;

-- 세션별 열린 커서 수 확인
SELECT s.sid, s.username, COUNT(*) AS open_cursors
FROM v$open_cursor o
JOIN v$session s ON o.sid = s.sid
WHERE s.type = 'USER'
GROUP BY s.sid, s.username
ORDER BY open_cursors DESC;

-- 설정 변경
ALTER SYSTEM SET open_cursors = 1000;
```

---

## 9. ORA-12899: value too large for column

```text
ORA-12899: value too large for column "DEVUSER"."EMPLOYEES"."NAME" (actual: 60, maximum: 50)
```

컬럼 크기보다 큰 데이터를 삽입하려 할 때 발생합니다.

```sql
-- 컬럼 크기 확인
SELECT column_name, data_type, data_length, char_length, char_used
FROM user_tab_columns
WHERE table_name = 'EMPLOYEES' AND column_name = 'NAME';

-- 컬럼 크기 확장
ALTER TABLE employees MODIFY (name VARCHAR2(100));

-- BYTE vs CHAR 확인
-- VARCHAR2(50 BYTE): 50바이트 (한글 약 16자)
-- VARCHAR2(50 CHAR): 50문자 (한글 50자)
ALTER TABLE employees MODIFY (name VARCHAR2(50 CHAR));
```

> 한글 환경에서는 `VARCHAR2(50 CHAR)` 형태로 CHAR 단위를 명시하는 것이 안전합니다.

---

## 10. ORA-28000: the account is locked

```text
ORA-28000: the account is locked
```

비밀번호 입력 실패 횟수 초과 또는 수동 잠금 시 발생합니다.

```sql
-- 계정 상태 확인
SELECT username, account_status, lock_date
FROM dba_users WHERE username = 'DEVUSER';

-- 계정 잠금 해제
ALTER USER devuser ACCOUNT UNLOCK;

-- 프로파일의 실패 허용 횟수 확인
SELECT resource_name, limit
FROM dba_profiles
WHERE profile = (SELECT profile FROM dba_users WHERE username = 'DEVUSER')
  AND resource_name = 'FAILED_LOGIN_ATTEMPTS';

-- 실패 허용 횟수 변경
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED;
-- 또는 적절한 값으로
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS 10;
```

---

## 11. ORA-01691: unable to extend lob segment

```text
ORA-01691: unable to extend lob segment DEVUSER.SYS_LOB... in tablespace USERS
```

LOB(CLOB, BLOB) 데이터가 저장되는 테이블스페이스 공간 부족입니다.

```sql
-- LOB 세그먼트 크기 확인
SELECT l.table_name, l.column_name, s.segment_name,
    ROUND(s.bytes/1024/1024, 2) AS size_mb
FROM user_lobs l
JOIN user_segments s ON l.segment_name = s.segment_name
ORDER BY s.bytes DESC;

-- 테이블스페이스 확장 (ORA-01653과 동일한 방법)
ALTER TABLESPACE users ADD DATAFILE '/opt/oracle/oradata/XE/users03.dbf' SIZE 1G AUTOEXTEND ON;
```

---

## 12. 성능 저하: 갑자기 느려진 쿼리

### 점검 체크리스트

| 순서 | 점검 항목 | 확인 방법 |
|:----:|----------|----------|
| 1 | 현재 활성 세션 확인 | `SELECT * FROM v$session WHERE status = 'ACTIVE'` |
| 2 | 락 대기 여부 | `v$lock`, `v$locked_object` |
| 3 | 실행 계획 변경 여부 | `EXPLAIN PLAN` 재확인 |
| 4 | 통계 정보 갱신 | `DBMS_STATS.GATHER_TABLE_STATS` |
| 5 | Undo/Temp 사용량 | `v$undostat`, `v$tempseg_usage` |
| 6 | I/O 대기 | `v$session_wait` |
| 7 | AWR 리포트 비교 | 정상 시점 vs 현재 비교 |

```sql
-- 현재 대기 이벤트 확인
SELECT event, wait_class, COUNT(*) AS sessions
FROM v$session
WHERE status = 'ACTIVE' AND type = 'USER'
GROUP BY event, wait_class
ORDER BY sessions DESC;

-- 통계 갱신 (실행 계획이 갑자기 바뀐 경우)
EXEC DBMS_STATS.GATHER_TABLE_STATS('DEVUSER', 'EMPLOYEES', CASCADE => TRUE);

-- SQL Plan Baseline으로 실행 계획 고정 (좋은 실행 계획을 알고 있을 때)
DECLARE
    v_plans PLS_INTEGER;
BEGIN
    v_plans := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(sql_id => 'abc123def456');
END;
/
```

---

## 13. ORA-04068: existing state of packages has been discarded

```text
ORA-04068: existing state of packages has been discarded
```

패키지가 재컴파일되어 기존 세션의 패키지 상태가 무효화된 경우입니다.

```sql
-- 무효 객체 확인
SELECT object_name, object_type, status
FROM user_objects
WHERE status = 'INVALID';

-- 무효 객체 재컴파일
ALTER PACKAGE pkg_employee COMPILE;
ALTER PACKAGE pkg_employee COMPILE BODY;

-- 전체 무효 객체 재컴파일
@$ORACLE_HOME/rdbms/admin/utlrp.sql

-- 또는 PL/SQL로
EXEC DBMS_UTILITY.COMPILE_SCHEMA('DEVUSER');
```

---

## 트러블슈팅 필수 명령어 요약

```sql
-- 인스턴스 상태
SELECT instance_name, status, database_status FROM v$instance;

-- 현재 세션/프로세스
SELECT sid, serial#, username, status, event, sql_id FROM v$session WHERE type = 'USER';

-- 락 확인
SELECT * FROM v$locked_object;

-- Alert 로그 위치
SELECT value FROM v$diag_info WHERE name = 'Diag Trace';

-- 테이블스페이스 사용량
SELECT tablespace_name, ROUND(SUM(bytes)/1024/1024) AS total_mb
FROM dba_data_files GROUP BY tablespace_name;

-- 무효 객체
SELECT object_name, object_type FROM user_objects WHERE status = 'INVALID';

-- 세션 강제 종료
ALTER SYSTEM KILL SESSION 'sid,serial#' IMMEDIATE;
```

{% assign c-category = 'oracle' %}
{% assign c-tag = 'lecture-oracle' %}
{% include /custom-ref.html %}

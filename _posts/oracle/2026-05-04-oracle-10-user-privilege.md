---
title: "[Oracle] 10. 사용자 관리와 권한 (User & Privilege)"
categories: 
    - oracle
tags: 
    [oracle, oracle강좌, 중급, 'lecture-oracle']
toc : true
toc_sticky  : true    
---

Oracle의 사용자 생성, 권한 부여, 롤(Role), 프로파일 관리를 정리합니다.

# 사용자 관리

## 사용자 생성
```sql
-- CDB 환경 (Oracle 12c+): PDB에 접속 후 생성
ALTER SESSION SET CONTAINER = XEPDB1;

-- 사용자 생성
CREATE USER devuser IDENTIFIED BY "DevPass123!"
  DEFAULT TABLESPACE users
  TEMPORARY TABLESPACE temp
  QUOTA UNLIMITED ON users;

-- CDB 공통 사용자 (C## 접두사 필요)
CREATE USER C##admin IDENTIFIED BY "AdminPass123!"
  CONTAINER = ALL;
```

### 사용자 조회
```sql
-- 전체 사용자 목록
SELECT username, account_status, default_tablespace, created
FROM dba_users
ORDER BY created DESC;

-- 현재 접속 사용자
SELECT USER FROM DUAL;
SELECT SYS_CONTEXT('USERENV', 'SESSION_USER') FROM DUAL;
```

### 비밀번호 변경
```sql
-- 다른 사용자 비밀번호 변경 (DBA 권한 필요)
ALTER USER devuser IDENTIFIED BY "NewPass456!";

-- 비밀번호 만료 설정
ALTER USER devuser PASSWORD EXPIRE;

-- 계정 잠금 / 해제
ALTER USER devuser ACCOUNT LOCK;
ALTER USER devuser ACCOUNT UNLOCK;
```

### 사용자 삭제
```sql
-- 사용자 삭제 (소유 객체가 없는 경우)
DROP USER devuser;

-- 소유 객체 포함 삭제
DROP USER devuser CASCADE;
```

---

## 권한 (Privilege)

Oracle의 권한은 시스템 권한과 객체 권한으로 나뉩니다.

### 시스템 권한 (System Privilege)

데이터베이스 수준의 작업 권한입니다.

```sql
-- 시스템 권한 부여
GRANT CREATE SESSION TO devuser;          -- 접속 권한
GRANT CREATE TABLE TO devuser;            -- 테이블 생성
GRANT CREATE VIEW TO devuser;             -- 뷰 생성
GRANT CREATE SEQUENCE TO devuser;         -- 시퀀스 생성
GRANT CREATE PROCEDURE TO devuser;        -- 프로시저/함수 생성
GRANT CREATE SYNONYM TO devuser;          -- 시노님 생성
GRANT UNLIMITED TABLESPACE TO devuser;    -- 테이블스페이스 무제한 사용

-- 여러 권한 한번에
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE TO devuser;
```

#### 주요 시스템 권한

| 권한 | 설명 |
|------|------|
| CREATE SESSION | DB 접속 |
| CREATE TABLE | 테이블 생성 |
| CREATE VIEW | 뷰 생성 |
| CREATE SEQUENCE | 시퀀스 생성 |
| CREATE PROCEDURE | 프로시저/함수 생성 |
| CREATE TRIGGER | 트리거 생성 |
| CREATE SYNONYM | 시노님 생성 |
| CREATE ANY TABLE | 모든 스키마에 테이블 생성 |
| SELECT ANY TABLE | 모든 테이블 조회 |
| DROP ANY TABLE | 모든 테이블 삭제 |
| ALTER SYSTEM | 시스템 파라미터 변경 |
| DBA | 모든 시스템 권한 |

### 객체 권한 (Object Privilege)

특정 객체(테이블, 뷰 등)에 대한 권한입니다.

```sql
-- 특정 테이블 권한
GRANT SELECT ON hr.employees TO devuser;
GRANT INSERT, UPDATE ON hr.employees TO devuser;
GRANT DELETE ON hr.employees TO devuser;

-- 특정 컬럼만 권한
GRANT UPDATE (salary, dept_id) ON hr.employees TO devuser;

-- 프로시저 실행 권한
GRANT EXECUTE ON hr.pkg_employee TO devuser;

-- 시퀀스 사용 권한
GRANT SELECT ON hr.seq_emp TO devuser;

-- 권한 부여 권한 포함 (WITH GRANT OPTION)
GRANT SELECT ON hr.employees TO devuser WITH GRANT OPTION;
```

### 권한 확인
```sql
-- 부여된 시스템 권한
SELECT privilege FROM dba_sys_privs WHERE grantee = 'DEVUSER';

-- 부여된 객체 권한
SELECT owner, table_name, privilege
FROM dba_tab_privs WHERE grantee = 'DEVUSER';

-- 현재 사용자의 권한
SELECT * FROM session_privs;
```

### 권한 회수 (REVOKE)
```sql
REVOKE CREATE TABLE FROM devuser;
REVOKE SELECT ON hr.employees FROM devuser;
REVOKE ALL ON hr.employees FROM devuser;
```

---

## 롤 (Role)

롤은 권한의 집합으로, 여러 사용자에게 동일한 권한을 효율적으로 관리합니다.

### 사전 정의 롤

| 롤 | 포함 권한 |
|----|----------|
| CONNECT | CREATE SESSION |
| RESOURCE | CREATE TABLE, CREATE SEQUENCE, CREATE PROCEDURE, CREATE TRIGGER 등 |
| DBA | 모든 시스템 권한 |
| SELECT_CATALOG_ROLE | 딕셔너리 뷰 조회 |

```sql
-- 기본 롤 부여 (가장 일반적)
GRANT CONNECT, RESOURCE TO devuser;
```

### 사용자 정의 롤
```sql
-- 롤 생성
CREATE ROLE app_readonly;
CREATE ROLE app_readwrite;
CREATE ROLE app_admin;

-- 롤에 권한 부여
GRANT SELECT ON hr.employees TO app_readonly;
GRANT SELECT ON hr.departments TO app_readonly;

GRANT SELECT, INSERT, UPDATE, DELETE ON hr.employees TO app_readwrite;
GRANT SELECT, INSERT, UPDATE, DELETE ON hr.departments TO app_readwrite;

GRANT app_readwrite TO app_admin;
GRANT CREATE TABLE, CREATE VIEW TO app_admin;

-- 사용자에게 롤 부여
GRANT app_readonly TO report_user;
GRANT app_readwrite TO devuser;
GRANT app_admin TO admin_user;

-- 기본 롤 설정
ALTER USER devuser DEFAULT ROLE app_readwrite;

-- 롤 확인
SELECT granted_role, default_role FROM dba_role_privs WHERE grantee = 'DEVUSER';

-- 롤 회수
REVOKE app_readwrite FROM devuser;

-- 롤 삭제
DROP ROLE app_readonly;
```

---

## 프로파일 (Profile)

프로파일은 사용자의 리소스 사용량과 비밀번호 정책을 제어합니다.

```sql
-- 프로파일 생성
CREATE PROFILE prof_developer LIMIT
    -- 비밀번호 정책
    FAILED_LOGIN_ATTEMPTS 5          -- 5회 실패 시 잠금
    PASSWORD_LOCK_TIME 1/24          -- 1시간 후 자동 해제
    PASSWORD_LIFE_TIME 90            -- 90일 후 만료
    PASSWORD_GRACE_TIME 7            -- 만료 후 7일 유예
    PASSWORD_REUSE_TIME 365          -- 365일 이내 동일 비밀번호 재사용 불가
    PASSWORD_REUSE_MAX 5             -- 최근 5개 비밀번호 재사용 불가
    -- 리소스 제한
    SESSIONS_PER_USER 5              -- 동시 세션 5개
    IDLE_TIME 30                     -- 30분 유휴 시 자동 종료
    CONNECT_TIME 480;                -- 최대 접속 시간 480분

-- 프로파일 적용
ALTER USER devuser PROFILE prof_developer;

-- 프로파일 확인
SELECT profile, resource_name, limit
FROM dba_profiles
WHERE profile = 'PROF_DEVELOPER';

-- 프로파일 삭제
DROP PROFILE prof_developer CASCADE;
```

---

## 실무 사용자 구성 예시

| 용도 | 사용자 | 권한/롤 |
|------|--------|--------|
| 애플리케이션 | app_user | CONNECT + 객체 권한 (SELECT, INSERT, UPDATE, DELETE) |
| 읽기 전용 | report_user | CONNECT + SELECT 권한만 |
| 개발자 | dev_user | CONNECT, RESOURCE + 개발 DB 객체 권한 |
| DBA | dba_user | DBA 롤 |
| 배치 | batch_user | CONNECT + 필요 프로시저 EXECUTE 권한 |

```sql
-- 애플리케이션 사용자
CREATE USER app_user IDENTIFIED BY "AppSecure123!"
  DEFAULT TABLESPACE users QUOTA 1G ON users;
GRANT CONNECT TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON hr.employees TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON hr.orders TO app_user;
GRANT EXECUTE ON hr.pkg_employee TO app_user;

-- 읽기 전용 사용자
CREATE USER report_user IDENTIFIED BY "ReportPass123!"
  DEFAULT TABLESPACE users QUOTA 0 ON users;
GRANT CONNECT TO report_user;
GRANT SELECT ON hr.employees TO report_user;
GRANT SELECT ON hr.v_emp_dept TO report_user;
```

{% assign c-category = 'oracle' %}
{% assign c-tag = 'lecture-oracle' %}
{% include /custom-ref.html %}

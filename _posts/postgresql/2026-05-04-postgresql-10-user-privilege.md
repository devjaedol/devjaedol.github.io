---
title: "[PostgreSQL] 10. 사용자 관리와 권한 (Role & Privilege)"
categories: 
    - postgresql
tags: 
    [postgresql, postgres, postgresql강좌, 중급, 'lecture-postgresql']
toc : true
toc_sticky  : true    
---

PostgreSQL의 롤(Role) 기반 사용자 관리와 권한 설정을 정리합니다.

# 롤 (Role) 개념

PostgreSQL에서는 사용자(User)와 그룹(Group)을 구분하지 않고 모두 Role로 통합합니다.    
`LOGIN` 속성이 있으면 사용자, 없으면 그룹 역할을 합니다.

## 롤 생성
```sql
-- 로그인 가능한 롤 (= 사용자)
CREATE ROLE devuser WITH LOGIN PASSWORD 'DevPass123!';

-- CREATE USER는 CREATE ROLE + LOGIN의 축약
CREATE USER devuser WITH PASSWORD 'DevPass123!';

-- 다양한 속성 지정
CREATE ROLE admin_user WITH
    LOGIN
    PASSWORD 'AdminPass123!'
    SUPERUSER
    CREATEDB
    CREATEROLE
    VALID UNTIL '2027-12-31';

-- 그룹 롤 (로그인 불가)
CREATE ROLE app_readonly;
CREATE ROLE app_readwrite;
```

## 롤 속성

| 속성 | 설명 |
|------|------|
| LOGIN / NOLOGIN | 로그인 가능 여부 |
| SUPERUSER / NOSUPERUSER | 슈퍼유저 여부 |
| CREATEDB / NOCREATEDB | DB 생성 권한 |
| CREATEROLE / NOCREATEROLE | 롤 생성 권한 |
| REPLICATION / NOREPLICATION | 복제 권한 |
| PASSWORD 'xxx' | 비밀번호 설정 |
| VALID UNTIL 'timestamp' | 계정 만료일 |
| CONNECTION LIMIT n | 최대 동시 접속 수 |
| INHERIT / NOINHERIT | 그룹 롤 권한 자동 상속 |

## 롤 조회 및 관리
```sql
-- 롤 목록
\du
SELECT rolname, rolsuper, rolcreatedb, rolcanlogin FROM pg_roles;

-- 비밀번호 변경
ALTER ROLE devuser WITH PASSWORD 'NewPass456!';

-- 속성 변경
ALTER ROLE devuser WITH CREATEDB;
ALTER ROLE devuser WITH CONNECTION LIMIT 5;

-- 롤 삭제
DROP ROLE devuser;
DROP ROLE IF EXISTS devuser;
```

---

## 그룹 롤 (권한 그룹)

```sql
-- 그룹 롤 생성 및 권한 부여
CREATE ROLE app_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_readonly;

CREATE ROLE app_readwrite;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_readwrite;

-- 사용자에게 그룹 롤 부여
GRANT app_readonly TO report_user;
GRANT app_readwrite TO devuser;

-- 그룹 롤 회수
REVOKE app_readwrite FROM devuser;

-- 멤버십 확인
SELECT r.rolname AS role, m.rolname AS member
FROM pg_auth_members am
JOIN pg_roles r ON r.oid = am.roleid
JOIN pg_roles m ON m.oid = am.member;
```

---

## 권한 관리 (GRANT / REVOKE)

### 데이터베이스 수준
```sql
GRANT CONNECT ON DATABASE mydb TO devuser;
GRANT CREATE ON DATABASE mydb TO devuser;
REVOKE ALL ON DATABASE mydb FROM devuser;
```

### 스키마 수준
```sql
GRANT USAGE ON SCHEMA app TO devuser;
GRANT CREATE ON SCHEMA app TO devuser;
GRANT ALL ON SCHEMA app TO devuser;
```

### 테이블 수준
```sql
-- 특정 테이블
GRANT SELECT ON employees TO devuser;
GRANT INSERT, UPDATE, DELETE ON employees TO devuser;
GRANT ALL ON employees TO devuser;

-- 특정 컬럼만
GRANT SELECT (name, dept_id), UPDATE (salary) ON employees TO devuser;

-- 스키마 내 모든 테이블
GRANT SELECT ON ALL TABLES IN SCHEMA public TO devuser;

-- 향후 생성될 테이블에도 자동 적용
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO app_readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_readwrite;
```

### 시퀀스 권한
```sql
GRANT USAGE ON SEQUENCE employees_id_seq TO devuser;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO devuser;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE ON SEQUENCES TO app_readwrite;
```

### 함수 권한
```sql
GRANT EXECUTE ON FUNCTION fn_salary_grade(NUMERIC) TO devuser;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO devuser;
```

### 권한 확인
```sql
-- 테이블 권한 확인
\dp employees
SELECT grantee, privilege_type
FROM information_schema.table_privileges
WHERE table_name = 'employees';

-- 현재 사용자 확인
SELECT current_user, session_user;
```

### 권한 회수
```sql
REVOKE INSERT ON employees FROM devuser;
REVOKE ALL ON employees FROM devuser;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM devuser;
```

---

## pg_hba.conf (접속 인증 설정)

PostgreSQL의 접속 인증은 `pg_hba.conf` 파일에서 관리합니다.

```text
# TYPE  DATABASE  USER      ADDRESS         METHOD
local   all       postgres                  peer
host    all       all       127.0.0.1/32    scram-sha-256
host    all       all       192.168.1.0/24  scram-sha-256
host    mydb      devuser   10.0.0.0/8      scram-sha-256
host    all       all       0.0.0.0/0       reject
```

| METHOD | 설명 |
|--------|------|
| trust | 무조건 허용 (비권장) |
| peer | OS 사용자명과 DB 사용자명 일치 시 허용 (로컬) |
| scram-sha-256 | 비밀번호 인증 (권장) |
| md5 | MD5 비밀번호 인증 (레거시) |
| reject | 접속 거부 |
| cert | SSL 인증서 |

```sql
-- pg_hba.conf 위치 확인
SHOW hba_file;

-- 설정 변경 후 리로드
SELECT pg_reload_conf();
-- 또는
-- sudo systemctl reload postgresql
```

---

## 실무 사용자 구성 예시

| 용도 | 롤 | 권한 |
|------|-----|------|
| 애플리케이션 | app_user | SELECT, INSERT, UPDATE, DELETE + USAGE ON SEQUENCES |
| 읽기 전용 | report_user | SELECT |
| 개발자 | dev_user | ALL ON 개발 DB |
| DBA | dba_user | SUPERUSER |
| 마이그레이션 | migration_user | ALL + CREATE |

```sql
-- 애플리케이션 사용자
CREATE USER app_user WITH PASSWORD 'AppSecure123!';
GRANT CONNECT ON DATABASE production_db TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO app_user;
```

{% assign c-category = 'postgresql' %}
{% assign c-tag = 'lecture-postgresql' %}
{% include /custom-ref.html %}

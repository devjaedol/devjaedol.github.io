---
title: "[MySQL] 10. 사용자 관리와 권한 (User & Privilege)"
categories: 
    - mysql
tags: 
    [mysql, mariadb, mysql강좌, 중급, 'lecture-mysql']
toc : true
toc_sticky  : true    
---

MySQL/MariaDB의 사용자 생성, 권한 부여, 보안 설정을 정리합니다.

# 사용자 관리

### 사용자 생성
```sql
-- 기본 생성 (로컬 접속만 허용)
CREATE USER 'devuser'@'localhost' IDENTIFIED BY 'password123!';

-- 특정 IP에서 접속 허용
CREATE USER 'devuser'@'192.168.1.100' IDENTIFIED BY 'password123!';

-- 모든 호스트에서 접속 허용
CREATE USER 'devuser'@'%' IDENTIFIED BY 'password123!';

-- 이미 존재하면 무시
CREATE USER IF NOT EXISTS 'devuser'@'%' IDENTIFIED BY 'password123!';
```

### 호스트 지정 패턴

| 패턴 | 설명 |
|------|------|
| `localhost` | 로컬 접속만 |
| `%` | 모든 호스트 |
| `192.168.1.%` | 192.168.1.x 대역 |
| `192.168.1.100` | 특정 IP만 |
| `%.example.com` | 특정 도메인 |

### 사용자 조회
```sql
-- 전체 사용자 목록
SELECT user, host FROM mysql.user;

-- 현재 접속 사용자 확인
SELECT USER(), CURRENT_USER();
```

### 비밀번호 변경
```sql
-- MySQL 8.0+
ALTER USER 'devuser'@'%' IDENTIFIED BY 'newpassword456!';

-- 현재 사용자 비밀번호 변경
ALTER USER USER() IDENTIFIED BY 'newpassword456!';

-- MySQL 5.7 이하
SET PASSWORD FOR 'devuser'@'%' = PASSWORD('newpassword456!');
```

### 사용자 삭제
```sql
DROP USER 'devuser'@'%';
DROP USER IF EXISTS 'devuser'@'%';
```

---

## 권한 관리

### 권한 부여 (GRANT)
```sql
-- 특정 데이터베이스의 모든 권한
GRANT ALL PRIVILEGES ON mydb.* TO 'devuser'@'%';

-- 특정 테이블의 특정 권한
GRANT SELECT, INSERT, UPDATE ON mydb.employees TO 'devuser'@'%';

-- 특정 컬럼만 권한 부여
GRANT SELECT (name, dept_id), UPDATE (salary) ON mydb.employees TO 'devuser'@'%';

-- 읽기 전용 사용자
GRANT SELECT ON mydb.* TO 'readonly'@'%';

-- 모든 데이터베이스에 대한 권한
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%';

-- 권한 부여 권한까지 포함 (WITH GRANT OPTION)
GRANT ALL PRIVILEGES ON mydb.* TO 'admin'@'%' WITH GRANT OPTION;

-- 권한 즉시 적용
FLUSH PRIVILEGES;
```

### 주요 권한 종류

| 권한 | 설명 |
|------|------|
| SELECT | 데이터 조회 |
| INSERT | 데이터 삽입 |
| UPDATE | 데이터 수정 |
| DELETE | 데이터 삭제 |
| CREATE | 데이터베이스/테이블 생성 |
| DROP | 데이터베이스/테이블 삭제 |
| ALTER | 테이블 구조 변경 |
| INDEX | 인덱스 생성/삭제 |
| EXECUTE | 프로시저/함수 실행 |
| CREATE VIEW | 뷰 생성 |
| TRIGGER | 트리거 생성 |
| REFERENCES | 외래키 생성 |
| ALL PRIVILEGES | 모든 권한 |

### 권한 확인
```sql
-- 특정 사용자의 권한 확인
SHOW GRANTS FOR 'devuser'@'%';

-- 현재 사용자의 권한 확인
SHOW GRANTS;
```

### 권한 회수 (REVOKE)
```sql
-- 특정 권한 회수
REVOKE INSERT, UPDATE ON mydb.employees FROM 'devuser'@'%';

-- 모든 권한 회수
REVOKE ALL PRIVILEGES ON mydb.* FROM 'devuser'@'%';

FLUSH PRIVILEGES;
```

---

## 역할 (Role) - MySQL 8.0+

역할을 사용하면 여러 사용자에게 동일한 권한 세트를 효율적으로 관리할 수 있습니다.

```sql
-- 역할 생성
CREATE ROLE 'app_read', 'app_write', 'app_admin';

-- 역할에 권한 부여
GRANT SELECT ON mydb.* TO 'app_read';
GRANT INSERT, UPDATE, DELETE ON mydb.* TO 'app_write';
GRANT ALL PRIVILEGES ON mydb.* TO 'app_admin';

-- 사용자에게 역할 부여
GRANT 'app_read', 'app_write' TO 'devuser'@'%';
GRANT 'app_admin' TO 'admin'@'%';

-- 역할 활성화
SET DEFAULT ROLE ALL TO 'devuser'@'%';

-- 역할 회수
REVOKE 'app_write' FROM 'devuser'@'%';

-- 역할 삭제
DROP ROLE 'app_read';
```

---

## 실무 사용자 구성 예시

| 용도 | 사용자 | 권한 |
|------|--------|------|
| 애플리케이션 | `app_user@'10.0.%'` | SELECT, INSERT, UPDATE, DELETE |
| 읽기 전용 (리포트) | `report_user@'%'` | SELECT |
| 개발자 | `dev_user@'192.168.%'` | ALL (개발 DB만) |
| DBA | `dba_user@'localhost'` | ALL + WITH GRANT OPTION |
| 백업 | `backup_user@'localhost'` | SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER |

```sql
-- 애플리케이션 사용자
CREATE USER 'app_user'@'10.0.%' IDENTIFIED BY 'SecureP@ss1!';
GRANT SELECT, INSERT, UPDATE, DELETE ON production_db.* TO 'app_user'@'10.0.%';

-- 백업 사용자
CREATE USER 'backup_user'@'localhost' IDENTIFIED BY 'BackupP@ss1!';
GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON *.* TO 'backup_user'@'localhost';

FLUSH PRIVILEGES;
```

---

## 보안 권장 사항

| 항목 | 권장 사항 |
|------|----------|
| root 원격 접속 | 차단 (`root@localhost`만 허용) |
| 비밀번호 정책 | 복잡도 설정 (대소문자, 숫자, 특수문자) |
| 최소 권한 원칙 | 필요한 권한만 부여 |
| 익명 사용자 | 삭제 (`mysql_secure_installation` 실행) |
| test DB | 삭제 |
| 접속 호스트 | `%` 대신 구체적인 IP/대역 지정 |

```sql
-- 비밀번호 정책 확인 (MySQL 8.0+)
SHOW VARIABLES LIKE 'validate_password%';

-- 비밀번호 정책 설정
SET GLOBAL validate_password.length = 12;
SET GLOBAL validate_password.policy = STRONG;
```

{% assign c-category = 'mysql' %}
{% assign c-tag = 'lecture-mysql' %}
{% include /custom-ref.html %}

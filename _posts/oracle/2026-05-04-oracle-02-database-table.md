---
title: "[Oracle] 02. 테이블스페이스와 테이블 관리"
categories: 
    - oracle
tags: 
    [oracle, oracle강좌, 초급, 'lecture-oracle']
toc : true
toc_sticky  : true    
---

Oracle의 테이블스페이스, 스키마, 테이블 생성 및 관리 방법을 정리합니다.

# 테이블스페이스 (Tablespace)

테이블스페이스는 Oracle에서 데이터를 물리적으로 저장하는 논리적 공간 단위입니다.    
MySQL의 `CREATE DATABASE`에 해당하는 개념이지만, 물리적 파일과 직접 연결됩니다.

## 테이블스페이스 생성
```sql
-- 기본 생성
CREATE TABLESPACE ts_myapp
  DATAFILE '/opt/oracle/oradata/XE/ts_myapp01.dbf'
  SIZE 500M
  AUTOEXTEND ON NEXT 100M MAXSIZE 5G;

-- Windows 경로
CREATE TABLESPACE ts_myapp
  DATAFILE 'C:\app\oracle\oradata\XE\ts_myapp01.dbf'
  SIZE 500M
  AUTOEXTEND ON NEXT 100M MAXSIZE 5G;

-- 임시 테이블스페이스
CREATE TEMPORARY TABLESPACE ts_temp
  TEMPFILE '/opt/oracle/oradata/XE/ts_temp01.dbf'
  SIZE 200M
  AUTOEXTEND ON;
```

### 테이블스페이스 조회 및 관리
```sql
-- 테이블스페이스 목록
SELECT tablespace_name, status, contents FROM dba_tablespaces;

-- 데이터파일 정보
SELECT tablespace_name, file_name, bytes/1024/1024 AS size_mb,
       autoextensible
FROM dba_data_files;

-- 사용량 확인
SELECT 
    t.tablespace_name,
    ROUND(t.total_mb, 2) AS total_mb,
    ROUND(t.total_mb - f.free_mb, 2) AS used_mb,
    ROUND(f.free_mb, 2) AS free_mb,
    ROUND((1 - f.free_mb / t.total_mb) * 100, 1) AS used_pct
FROM 
    (SELECT tablespace_name, SUM(bytes)/1024/1024 AS total_mb FROM dba_data_files GROUP BY tablespace_name) t,
    (SELECT tablespace_name, SUM(bytes)/1024/1024 AS free_mb FROM dba_free_space GROUP BY tablespace_name) f
WHERE t.tablespace_name = f.tablespace_name
ORDER BY used_pct DESC;

-- 데이터파일 추가
ALTER TABLESPACE ts_myapp
  ADD DATAFILE '/opt/oracle/oradata/XE/ts_myapp02.dbf'
  SIZE 500M AUTOEXTEND ON;

-- 테이블스페이스 삭제
DROP TABLESPACE ts_myapp INCLUDING CONTENTS AND DATAFILES;
```

---

## 사용자(스키마) 생성

Oracle에서는 사용자 = 스키마입니다. 사용자를 생성하면 동일한 이름의 스키마가 자동 생성됩니다.

```sql
-- 사용자 생성 (Oracle 21c XE에서는 C## 접두사 필요하거나 PDB 사용)
-- PDB 접속 후 생성 (권장)
ALTER SESSION SET CONTAINER = XEPDB1;

CREATE USER devuser IDENTIFIED BY "DevPass123!"
  DEFAULT TABLESPACE ts_myapp
  TEMPORARY TABLESPACE ts_temp
  QUOTA UNLIMITED ON ts_myapp;

-- 기본 권한 부여
GRANT CONNECT, RESOURCE TO devuser;
GRANT CREATE VIEW, CREATE SYNONYM TO devuser;
```

---

## 테이블 관리

### 테이블 생성
```sql
CREATE TABLE employees (
    id          NUMBER(10)      NOT NULL,
    name        VARCHAR2(50)    NOT NULL,
    email       VARCHAR2(100)   NOT NULL,
    dept_id     NUMBER(10),
    salary      NUMBER(12,2)    DEFAULT 0,
    hire_date   DATE            DEFAULT SYSDATE,
    is_active   NUMBER(1)       DEFAULT 1,
    created_at  TIMESTAMP       DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_employees PRIMARY KEY (id),
    CONSTRAINT uk_emp_email UNIQUE (email)
);

-- 코멘트 추가 (Oracle 특유 기능)
COMMENT ON TABLE employees IS '직원 정보 테이블';
COMMENT ON COLUMN employees.id IS '직원 고유 ID';
COMMENT ON COLUMN employees.name IS '직원 이름';
COMMENT ON COLUMN employees.salary IS '급여 (원)';
```

### 주요 데이터 타입

#### Oracle vs MySQL 데이터 타입 매핑

| Oracle | MySQL | 설명 |
|--------|-------|------|
| NUMBER(p,s) | INT, DECIMAL | 숫자 (정밀도, 스케일) |
| NUMBER(10) | INT | 정수 |
| NUMBER(12,2) | DECIMAL(12,2) | 소수점 포함 |
| VARCHAR2(n) | VARCHAR(n) | 가변 길이 문자열 |
| CHAR(n) | CHAR(n) | 고정 길이 문자열 |
| CLOB | LONGTEXT | 대용량 텍스트 |
| BLOB | LONGBLOB | 대용량 바이너리 |
| DATE | DATETIME | 날짜 + 시간 (Oracle DATE는 시간 포함) |
| TIMESTAMP | TIMESTAMP | 밀리초 포함 날짜/시간 |
| NUMBER(1) | TINYINT(1) | 불리언 대용 |

> Oracle에는 `VARCHAR`도 있지만, Oracle은 공식적으로 `VARCHAR2` 사용을 권장합니다.

#### 숫자형 상세

| 타입 | 설명 | 예시 |
|------|------|------|
| NUMBER | 최대 38자리 정밀도 | `NUMBER` (제한 없음) |
| NUMBER(5) | 5자리 정수 | -99999 ~ 99999 |
| NUMBER(7,2) | 전체 7자리, 소수 2자리 | -99999.99 ~ 99999.99 |
| BINARY_FLOAT | 32비트 부동소수점 | 과학 계산 |
| BINARY_DOUBLE | 64비트 부동소수점 | 과학 계산 |

---

### 시퀀스 (SEQUENCE)

Oracle에는 AUTO_INCREMENT가 없습니다. 대신 SEQUENCE 객체를 사용합니다.

```sql
-- 시퀀스 생성
CREATE SEQUENCE seq_employees
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

-- 시퀀스 사용
INSERT INTO employees (id, name, email, salary)
VALUES (seq_employees.NEXTVAL, '홍길동', 'hong@test.com', 5000000);

-- 현재 값 확인
SELECT seq_employees.CURRVAL FROM DUAL;

-- 시퀀스 목록 조회
SELECT sequence_name, last_number, increment_by FROM user_sequences;

-- 시퀀스 삭제
DROP SEQUENCE seq_employees;
```

#### Oracle 12c+ IDENTITY 컬럼
Oracle 12c부터는 MySQL의 AUTO_INCREMENT와 유사한 IDENTITY 컬럼을 지원합니다.
```sql
CREATE TABLE employees (
    id    NUMBER GENERATED ALWAYS AS IDENTITY,
    name  VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_employees PRIMARY KEY (id)
);
```

---

### 테이블 조회
```sql
-- 현재 사용자의 테이블 목록
SELECT table_name FROM user_tables ORDER BY table_name;

-- 테이블 구조 확인
DESC employees;
DESCRIBE employees;

-- 테이블 컬럼 상세 정보
SELECT column_name, data_type, data_length, nullable, data_default
FROM user_tab_columns
WHERE table_name = 'EMPLOYEES'
ORDER BY column_id;

-- 테이블 코멘트 확인
SELECT table_name, comments FROM user_tab_comments WHERE table_name = 'EMPLOYEES';
SELECT column_name, comments FROM user_col_comments WHERE table_name = 'EMPLOYEES';

-- 테이블 DDL 추출
SELECT DBMS_METADATA.GET_DDL('TABLE', 'EMPLOYEES') FROM DUAL;
```

### 테이블 수정 (ALTER TABLE)
```sql
-- 컬럼 추가
ALTER TABLE employees ADD (phone VARCHAR2(20));

-- 컬럼 수정
ALTER TABLE employees MODIFY (phone VARCHAR2(30) NOT NULL);

-- 컬럼 이름 변경
ALTER TABLE employees RENAME COLUMN phone TO mobile;

-- 컬럼 삭제
ALTER TABLE employees DROP COLUMN mobile;

-- 테이블 이름 변경
ALTER TABLE employees RENAME TO members;
RENAME members TO employees;

-- 컬럼 기본값 변경
ALTER TABLE employees MODIFY (salary DEFAULT 3000000);
```

### 테이블 삭제
```sql
-- 테이블 삭제 (휴지통으로 이동)
DROP TABLE employees;

-- 완전 삭제 (휴지통 건너뜀)
DROP TABLE employees PURGE;

-- 휴지통 확인
SELECT object_name, original_name, droptime FROM recyclebin;

-- 휴지통에서 복구
FLASHBACK TABLE employees TO BEFORE DROP;

-- 휴지통 비우기
PURGE RECYCLEBIN;

-- 데이터만 삭제 (구조 유지)
TRUNCATE TABLE employees;
```

---

## 제약 조건 (Constraints)

| 제약 조건 | 설명 | 예시 |
|----------|------|------|
| PRIMARY KEY | 기본키 | `CONSTRAINT pk_emp PRIMARY KEY (id)` |
| UNIQUE | 중복 불가 | `CONSTRAINT uk_email UNIQUE (email)` |
| NOT NULL | NULL 불가 | `name VARCHAR2(50) NOT NULL` |
| CHECK | 값 범위 제한 | `CONSTRAINT ck_salary CHECK (salary >= 0)` |
| FOREIGN KEY | 외래키 참조 | 아래 예시 참고 |
| DEFAULT | 기본값 | `salary NUMBER DEFAULT 0` |

### 외래키 설정
```sql
CREATE TABLE orders (
    id          NUMBER GENERATED ALWAYS AS IDENTITY,
    emp_id      NUMBER(10) NOT NULL,
    product     VARCHAR2(100) NOT NULL,
    amount      NUMBER(12,2) NOT NULL,
    ordered_at  DATE DEFAULT SYSDATE,
    CONSTRAINT pk_orders PRIMARY KEY (id),
    CONSTRAINT fk_orders_emp FOREIGN KEY (emp_id)
        REFERENCES employees(id)
        ON DELETE CASCADE
);
```

> Oracle의 외래키는 `ON DELETE CASCADE`와 `ON DELETE SET NULL`만 지원합니다.    
> `ON UPDATE CASCADE`는 지원하지 않습니다 (MySQL과의 차이점).

### 제약 조건 관리
```sql
-- 제약 조건 조회
SELECT constraint_name, constraint_type, status
FROM user_constraints
WHERE table_name = 'EMPLOYEES';

-- 제약 조건 비활성화 / 활성화
ALTER TABLE employees DISABLE CONSTRAINT fk_orders_emp;
ALTER TABLE employees ENABLE CONSTRAINT fk_orders_emp;

-- 제약 조건 삭제
ALTER TABLE employees DROP CONSTRAINT uk_emp_email;
```

{% assign c-category = 'oracle' %}
{% assign c-tag = 'lecture-oracle' %}
{% include /custom-ref.html %}

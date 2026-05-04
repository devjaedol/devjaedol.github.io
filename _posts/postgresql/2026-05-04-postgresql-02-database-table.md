---
title: "[PostgreSQL] 02. 데이터베이스와 테이블 관리"
categories: 
    - postgresql
tags: 
    [postgresql, postgres, postgresql강좌, 초급, 'lecture-postgresql']
toc : true
toc_sticky  : true    
---

PostgreSQL의 데이터베이스, 스키마, 테이블 생성 및 관리 방법을 정리합니다.

# 데이터베이스 관리

## 데이터베이스 생성
```sql
-- 기본 생성
CREATE DATABASE mydb;

-- 옵션 지정
CREATE DATABASE mydb
  OWNER = devuser
  ENCODING = 'UTF8'
  LC_COLLATE = 'ko_KR.UTF-8'
  LC_CTYPE = 'ko_KR.UTF-8'
  TEMPLATE = template0;

-- 이미 존재하면 무시 (PostgreSQL 9.5+에서는 IF NOT EXISTS 미지원, 대안)
SELECT 'CREATE DATABASE mydb' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'mydb')\gexec
```

## 데이터베이스 조회 및 삭제
```sql
-- 데이터베이스 목록
\l
SELECT datname, datdba, encoding, datcollate FROM pg_database;

-- 현재 데이터베이스 확인
SELECT current_database();

-- 데이터베이스 전환 (psql)
\c mydb

-- 데이터베이스 삭제 (접속 중인 세션이 없어야 함)
DROP DATABASE mydb;
DROP DATABASE IF EXISTS mydb;
```

---

## 스키마 (Schema)

PostgreSQL의 스키마는 데이터베이스 내의 네임스페이스입니다.    
MySQL에서는 Database가 이 역할을 하지만, PostgreSQL은 Database > Schema > Table 3단계 구조입니다.

```sql
-- 스키마 생성
CREATE SCHEMA app;
CREATE SCHEMA IF NOT EXISTS app;

-- 스키마 목록
\dn
SELECT schema_name FROM information_schema.schemata;

-- 검색 경로 설정 (스키마명 생략 시 탐색 순서)
SET search_path TO app, public;
SHOW search_path;

-- 스키마 삭제
DROP SCHEMA app;
DROP SCHEMA app CASCADE;  -- 포함된 객체 모두 삭제
```

### 스키마 활용 예시
```sql
-- 스키마별 테이블 분리
CREATE SCHEMA sales;
CREATE SCHEMA hr;

CREATE TABLE sales.orders (id SERIAL PRIMARY KEY, amount NUMERIC);
CREATE TABLE hr.employees (id SERIAL PRIMARY KEY, name VARCHAR(50));

-- 스키마 지정 조회
SELECT * FROM sales.orders;
SELECT * FROM hr.employees;
```

---

## 테이블 관리

### 테이블 생성
```sql
CREATE TABLE employees (
    id          SERIAL          PRIMARY KEY,
    name        VARCHAR(50)     NOT NULL,
    email       VARCHAR(100)    NOT NULL UNIQUE,
    dept_id     INTEGER,
    salary      NUMERIC(12,2)   DEFAULT 0,
    is_active   BOOLEAN         DEFAULT TRUE,
    hire_date   DATE            DEFAULT CURRENT_DATE,
    created_at  TIMESTAMPTZ     DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     DEFAULT NOW()
);

-- 테이블 코멘트
COMMENT ON TABLE employees IS '직원 정보 테이블';
COMMENT ON COLUMN employees.id IS '직원 고유 ID';
COMMENT ON COLUMN employees.salary IS '급여 (원)';
```

### 주요 데이터 타입

#### 숫자형

| 타입 | 크기 | 범위 | MySQL 대응 |
|------|------|------|-----------|
| SMALLINT | 2byte | -32,768 ~ 32,767 | SMALLINT |
| INTEGER (INT) | 4byte | -21억 ~ 21억 | INT |
| BIGINT | 8byte | -922경 ~ 922경 | BIGINT |
| NUMERIC(p,s) | 가변 | 정밀 소수 | DECIMAL |
| REAL | 4byte | 6자리 정밀도 | FLOAT |
| DOUBLE PRECISION | 8byte | 15자리 정밀도 | DOUBLE |
| SERIAL | 4byte | 자동 증가 정수 | AUTO_INCREMENT |
| BIGSERIAL | 8byte | 자동 증가 큰 정수 | BIGINT AUTO_INCREMENT |

#### 문자형

| 타입 | 설명 | MySQL 대응 |
|------|------|-----------|
| VARCHAR(n) | 가변 길이 (최대 n자) | VARCHAR |
| CHAR(n) | 고정 길이 | CHAR |
| TEXT | 무제한 가변 길이 | LONGTEXT |

> PostgreSQL에서는 `VARCHAR`와 `TEXT`의 성능 차이가 없습니다. `TEXT`를 자유롭게 사용해도 됩니다.

#### 날짜/시간형

| 타입 | 설명 | MySQL 대응 |
|------|------|-----------|
| DATE | 날짜만 | DATE |
| TIME | 시간만 | TIME |
| TIMESTAMP | 날짜+시간 (시간대 없음) | DATETIME |
| TIMESTAMPTZ | 날짜+시간 (시간대 포함, 권장) | TIMESTAMP |
| INTERVAL | 시간 간격 | 없음 |

#### PostgreSQL 고유 타입

| 타입 | 설명 |
|------|------|
| BOOLEAN | true/false |
| UUID | 범용 고유 식별자 |
| JSONB | 바이너리 JSON (인덱싱 가능, 권장) |
| JSON | 텍스트 JSON |
| ARRAY | 배열 (INTEGER[], TEXT[] 등) |
| HSTORE | 키-값 쌍 |
| INET / CIDR | IP 주소 / 네트워크 |
| POINT / LINE / POLYGON | 기하학 타입 |
| TSVECTOR | 전문 검색용 |
| BYTEA | 바이너리 데이터 |

---

### 테이블 조회
```sql
-- 테이블 목록
\dt
\dt app.*   -- 특정 스키마

-- 테이블 구조
\d employees
\d+ employees   -- 상세 (코멘트 포함)

-- 테이블 DDL 추출 (pg_dump 사용)
-- pg_dump -U postgres -d mydb -t employees --schema-only
```

### 테이블 수정 (ALTER TABLE)
```sql
-- 컬럼 추가
ALTER TABLE employees ADD COLUMN phone VARCHAR(20);

-- 컬럼 타입 변경
ALTER TABLE employees ALTER COLUMN phone TYPE VARCHAR(30);

-- NOT NULL 추가/제거
ALTER TABLE employees ALTER COLUMN phone SET NOT NULL;
ALTER TABLE employees ALTER COLUMN phone DROP NOT NULL;

-- 기본값 설정/제거
ALTER TABLE employees ALTER COLUMN salary SET DEFAULT 3000000;
ALTER TABLE employees ALTER COLUMN salary DROP DEFAULT;

-- 컬럼 이름 변경
ALTER TABLE employees RENAME COLUMN phone TO mobile;

-- 컬럼 삭제
ALTER TABLE employees DROP COLUMN mobile;

-- 테이블 이름 변경
ALTER TABLE employees RENAME TO members;
ALTER TABLE members RENAME TO employees;
```

### 테이블 삭제
```sql
DROP TABLE employees;
DROP TABLE IF EXISTS employees;
DROP TABLE employees CASCADE;  -- 의존 객체 함께 삭제

-- 데이터만 삭제 (구조 유지)
TRUNCATE TABLE employees;
TRUNCATE TABLE employees RESTART IDENTITY;  -- SERIAL 리셋
TRUNCATE TABLE employees CASCADE;           -- FK 참조 테이블도 함께
```

---

## 제약 조건 (Constraints)

| 제약 조건 | 설명 | 예시 |
|----------|------|------|
| PRIMARY KEY | 기본키 | `id SERIAL PRIMARY KEY` |
| UNIQUE | 중복 불가 | `email VARCHAR(100) UNIQUE` |
| NOT NULL | NULL 불가 | `name VARCHAR(50) NOT NULL` |
| CHECK | 값 범위 제한 | `CHECK (salary >= 0)` |
| FOREIGN KEY | 외래키 참조 | 아래 예시 참고 |
| DEFAULT | 기본값 | `salary NUMERIC DEFAULT 0` |
| EXCLUDE | 범위 겹침 방지 (PostgreSQL 전용) | GiST 인덱스 활용 |

### 외래키 설정
```sql
CREATE TABLE orders (
    id          SERIAL PRIMARY KEY,
    emp_id      INTEGER NOT NULL,
    product     VARCHAR(100) NOT NULL,
    amount      NUMERIC(12,2) NOT NULL,
    ordered_at  TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_orders_emp FOREIGN KEY (emp_id)
        REFERENCES employees(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
```

### 제약 조건 관리
```sql
-- 제약 조건 조회
SELECT conname, contype, conrelid::regclass
FROM pg_constraint
WHERE conrelid = 'employees'::regclass;

-- 제약 조건 추가
ALTER TABLE employees ADD CONSTRAINT ck_salary CHECK (salary >= 0);

-- 제약 조건 삭제
ALTER TABLE employees DROP CONSTRAINT ck_salary;
```

{% assign c-category = 'postgresql' %}
{% assign c-tag = 'lecture-postgresql' %}
{% include /custom-ref.html %}

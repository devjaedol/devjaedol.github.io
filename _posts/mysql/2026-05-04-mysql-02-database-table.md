---
title: "[MySQL] 02. 데이터베이스와 테이블 관리"
categories: 
    - mysql
tags: 
    [mysql, mariadb, mysql강좌, 초급, 'lecture-mysql']
toc : true
toc_sticky  : true    
---

데이터베이스와 테이블의 생성, 수정, 삭제 등 DDL(Data Definition Language) 명령어를 정리합니다.

# 데이터베이스 관리

### 데이터베이스 생성
```sql
-- 기본 생성
CREATE DATABASE mydb;

-- 문자셋 지정 (권장)
CREATE DATABASE mydb
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

-- 이미 존재하면 무시
CREATE DATABASE IF NOT EXISTS mydb;
```

### 데이터베이스 조회
```sql
-- 전체 데이터베이스 목록
SHOW DATABASES;

-- 데이터베이스 생성 정보 확인
SHOW CREATE DATABASE mydb;
```

### 데이터베이스 선택 및 삭제
```sql
-- 사용할 데이터베이스 선택
USE mydb;

-- 현재 선택된 데이터베이스 확인
SELECT DATABASE();

-- 데이터베이스 삭제
DROP DATABASE mydb;
DROP DATABASE IF EXISTS mydb;
```

---

## 테이블 관리

### 테이블 생성
```sql
CREATE TABLE users (
    id          INT           NOT NULL AUTO_INCREMENT,
    username    VARCHAR(50)   NOT NULL,
    email       VARCHAR(100)  NOT NULL,
    password    VARCHAR(255)  NOT NULL,
    age         INT           DEFAULT 0,
    is_active   TINYINT(1)    DEFAULT 1,
    created_at  DATETIME      DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_email (email),
    INDEX idx_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 주요 데이터 타입

#### 숫자형

| 타입 | 크기 | 범위 (SIGNED) | 용도 |
|------|------|--------------|------|
| TINYINT | 1byte | -128 ~ 127 | 불리언, 상태값 |
| SMALLINT | 2byte | -32,768 ~ 32,767 | 작은 정수 |
| INT | 4byte | -21억 ~ 21억 | 일반 정수 |
| BIGINT | 8byte | -922경 ~ 922경 | 대용량 ID, 금액 |
| DECIMAL(M,D) | 가변 | 정밀 소수 | 금액 계산 (정확도 보장) |
| FLOAT | 4byte | 근사 소수 | 과학 계산 |
| DOUBLE | 8byte | 근사 소수 | 과학 계산 |

#### 문자형

| 타입 | 최대 크기 | 특징 |
|------|----------|------|
| CHAR(n) | 255자 | 고정 길이, 빠른 검색 |
| VARCHAR(n) | 65,535자 | 가변 길이, 공간 효율적 |
| TEXT | 65,535자 | 긴 텍스트 |
| MEDIUMTEXT | 16MB | 중간 크기 텍스트 |
| LONGTEXT | 4GB | 대용량 텍스트 |

#### 날짜/시간형

| 타입 | 형식 | 범위 |
|------|------|------|
| DATE | YYYY-MM-DD | 1000-01-01 ~ 9999-12-31 |
| TIME | HH:MM:SS | -838:59:59 ~ 838:59:59 |
| DATETIME | YYYY-MM-DD HH:MM:SS | 1000 ~ 9999년 |
| TIMESTAMP | YYYY-MM-DD HH:MM:SS | 1970 ~ 2038년 (UTC 자동 변환) |

---

### 테이블 조회
```sql
-- 테이블 목록
SHOW TABLES;

-- 테이블 구조 확인
DESC users;
DESCRIBE users;
SHOW COLUMNS FROM users;

-- 테이블 생성 SQL 확인
SHOW CREATE TABLE users;
```

### 테이블 수정 (ALTER TABLE)
```sql
-- 컬럼 추가
ALTER TABLE users ADD COLUMN phone VARCHAR(20) AFTER email;

-- 컬럼 수정
ALTER TABLE users MODIFY COLUMN phone VARCHAR(30) NOT NULL;

-- 컬럼 이름 변경
ALTER TABLE users CHANGE COLUMN phone mobile VARCHAR(30);

-- 컬럼 삭제
ALTER TABLE users DROP COLUMN mobile;

-- 인덱스 추가
ALTER TABLE users ADD INDEX idx_age (age);

-- 유니크 제약 추가
ALTER TABLE users ADD UNIQUE KEY uk_username (username);

-- 테이블 이름 변경
ALTER TABLE users RENAME TO members;
RENAME TABLE members TO users;
```

### 테이블 삭제 및 초기화
```sql
-- 테이블 삭제 (구조 + 데이터 모두 삭제)
DROP TABLE users;
DROP TABLE IF EXISTS users;

-- 테이블 데이터만 초기화 (구조 유지, AUTO_INCREMENT 리셋)
TRUNCATE TABLE users;
```

---

## 제약 조건 (Constraints)

| 제약 조건 | 설명 | 예시 |
|----------|------|------|
| PRIMARY KEY | 기본키, NOT NULL + UNIQUE | `PRIMARY KEY (id)` |
| UNIQUE | 중복 불가 | `UNIQUE KEY uk_email (email)` |
| NOT NULL | NULL 불가 | `username VARCHAR(50) NOT NULL` |
| DEFAULT | 기본값 설정 | `age INT DEFAULT 0` |
| CHECK | 값 범위 제한 (MySQL 8.0+) | `CHECK (age >= 0)` |
| FOREIGN KEY | 외래키 참조 | 아래 예시 참고 |

### 외래키 설정
```sql
CREATE TABLE orders (
    id          INT NOT NULL AUTO_INCREMENT,
    user_id     INT NOT NULL,
    product     VARCHAR(100) NOT NULL,
    amount      DECIMAL(10,2) NOT NULL,
    ordered_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

#### ON DELETE / ON UPDATE 옵션

| 옵션 | 설명 |
|------|------|
| CASCADE | 부모 삭제/수정 시 자식도 함께 삭제/수정 |
| SET NULL | 부모 삭제/수정 시 자식의 FK를 NULL로 설정 |
| RESTRICT | 자식이 있으면 부모 삭제/수정 불가 (기본값) |
| NO ACTION | RESTRICT와 동일 |
| SET DEFAULT | 기본값으로 설정 (InnoDB 미지원) |

{% assign c-category = 'mysql' %}
{% assign c-tag = 'lecture-mysql' %}
{% include /custom-ref.html %}

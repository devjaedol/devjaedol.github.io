---
title: "[PostgreSQL] 06. 내장 함수 정리"
categories: 
    - postgresql
tags: 
    [postgresql, postgres, postgresql강좌, 중급, 'lecture-postgresql']
toc : true
toc_sticky  : true    
---

PostgreSQL에서 자주 사용하는 내장 함수를 카테고리별로 정리합니다.

# 문자열 함수

| 함수 | 설명 | 예시 | 결과 |
|------|------|------|------|
| `\|\|` | 문자열 연결 | `'Hello' \|\| ' ' \|\| 'World'` | Hello World |
| CONCAT | 문자열 연결 (NULL 무시) | `CONCAT('A', NULL, 'B')` | AB |
| CONCAT_WS | 구분자로 연결 | `CONCAT_WS('-', '2024', '01', '15')` | 2024-01-15 |
| SUBSTRING | 부분 문자열 | `SUBSTRING('Hello' FROM 1 FOR 3)` | Hel |
| LEFT / RIGHT | 왼쪽/오른쪽 n자 | `LEFT('Hello', 2)` | He |
| LENGTH | 문자 길이 | `LENGTH('가나다')` | 3 |
| OCTET_LENGTH | 바이트 길이 | `OCTET_LENGTH('가나다')` | 9 |
| UPPER / LOWER | 대/소문자 | `UPPER('hello')` | HELLO |
| INITCAP | 첫 글자 대문자 | `INITCAP('hello world')` | Hello World |
| TRIM | 공백/문자 제거 | `TRIM('  hi  ')` | hi |
| LTRIM / RTRIM | 좌/우 제거 | `LTRIM('xxhi', 'x')` | hi |
| REPLACE | 문자열 치환 | `REPLACE('abc', 'b', 'x')` | axc |
| LPAD / RPAD | 패딩 | `LPAD('5', 3, '0')` | 005 |
| REVERSE | 뒤집기 | `REVERSE('abc')` | cba |
| POSITION | 위치 찾기 | `POSITION('lo' IN 'Hello')` | 4 |
| SPLIT_PART | 구분자로 분리 | `SPLIT_PART('a-b-c', '-', 2)` | b |
| REGEXP_REPLACE | 정규식 치환 | `REGEXP_REPLACE('abc123', '[0-9]', '', 'g')` | abc |
| TRANSLATE | 문자 단위 치환 | `TRANSLATE('abc', 'abc', 'xyz')` | xyz |
| FORMAT | 포맷 문자열 | `FORMAT('Hello %s, age %s', '홍길동', 30)` | Hello 홍길동, age 30 |

```sql
-- 이메일에서 도메인 추출
SELECT SPLIT_PART(email, '@', 2) AS domain FROM users;

-- 이름 마스킹
SELECT LEFT(name, 1) || '**' AS masked_name FROM employees;

-- 정규식 매칭
SELECT name FROM employees WHERE name ~ '^[가-힣]+$';  -- 한글만
```

---

## 숫자 함수

| 함수 | 설명 | 예시 | 결과 |
|------|------|------|------|
| ROUND | 반올림 | `ROUND(3.456, 2)` | 3.46 |
| CEIL / CEILING | 올림 | `CEIL(3.1)` | 4 |
| FLOOR | 내림 | `FLOOR(3.9)` | 3 |
| TRUNC | 절삭 | `TRUNC(3.456, 2)` | 3.45 |
| ABS | 절대값 | `ABS(-5)` | 5 |
| MOD | 나머지 | `MOD(10, 3)` | 1 |
| POWER | 거듭제곱 | `POWER(2, 10)` | 1024 |
| SQRT | 제곱근 | `SQRT(16)` | 4 |
| RANDOM | 난수 (0~1) | `RANDOM()` | 0.7342... |
| GREATEST | 최대값 | `GREATEST(1, 5, 3)` | 5 |
| LEAST | 최소값 | `LEAST(1, 5, 3)` | 1 |

```sql
-- 랜덤 정렬
SELECT * FROM employees ORDER BY RANDOM() LIMIT 3;

-- 급여를 만원 단위로 반올림
SELECT name, ROUND(salary, -4) AS rounded FROM employees;
```

---

## 날짜/시간 함수

| 함수 | 설명 | MySQL 대응 |
|------|------|-----------|
| NOW() | 현재 날짜+시간 (트랜잭션 시작 시점) | NOW() |
| CURRENT_TIMESTAMP | NOW()와 동일 | CURRENT_TIMESTAMP |
| CURRENT_DATE | 현재 날짜 | CURDATE() |
| CURRENT_TIME | 현재 시간 | CURTIME() |
| CLOCK_TIMESTAMP() | 실제 현재 시각 (호출 시점) | 없음 |
| EXTRACT | 연/월/일 추출 | EXTRACT |
| DATE_TRUNC | 날짜 절삭 | 없음 |
| AGE | 두 날짜 간 차이 | TIMESTAMPDIFF |
| DATE_PART | 날짜 부분 추출 | YEAR(), MONTH() |
| TO_CHAR | 날짜 포맷 | DATE_FORMAT |
| TO_DATE | 문자→날짜 | STR_TO_DATE |
| TO_TIMESTAMP | 문자→타임스탬프 | STR_TO_DATE |
| INTERVAL | 시간 간격 | INTERVAL |

```sql
-- 현재 날짜/시간
SELECT NOW();                    -- 2026-05-04 14:30:00+09
SELECT CURRENT_DATE;             -- 2026-05-04
SELECT CLOCK_TIMESTAMP();       -- 실제 호출 시점 (반복 호출 시 값이 다름)

-- 날짜 연산 (INTERVAL 사용)
SELECT NOW() + INTERVAL '7 days';
SELECT NOW() - INTERVAL '1 month';
SELECT NOW() + INTERVAL '2 hours 30 minutes';

-- EXTRACT
SELECT EXTRACT(YEAR FROM NOW());    -- 2026
SELECT EXTRACT(MONTH FROM NOW());   -- 5
SELECT EXTRACT(DOW FROM NOW());     -- 0(일)~6(토)

-- DATE_TRUNC (날짜 절삭, PostgreSQL 전용)
SELECT DATE_TRUNC('month', NOW());  -- 2026-05-01 00:00:00
SELECT DATE_TRUNC('year', NOW());   -- 2026-01-01 00:00:00
SELECT DATE_TRUNC('hour', NOW());   -- 2026-05-04 14:00:00

-- AGE (두 날짜 간 차이)
SELECT AGE(NOW(), '2024-01-01');    -- 2 years 4 mons 3 days

-- TO_CHAR (날짜 포맷)
SELECT TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS');
SELECT TO_CHAR(NOW(), 'YYYY"년" MM"월" DD"일"');

-- TO_DATE / TO_TIMESTAMP
SELECT TO_DATE('2026-05-04', 'YYYY-MM-DD');
SELECT TO_TIMESTAMP('2026-05-04 14:30:00', 'YYYY-MM-DD HH24:MI:SS');

-- 입사 후 근속 연수
SELECT name, hire_date,
    EXTRACT(YEAR FROM AGE(NOW(), hire_date))::INTEGER AS 근속연수
FROM employees;
```

---

## NULL 처리 함수

| PostgreSQL | MySQL 대응 | 설명 |
|-----------|-----------|------|
| COALESCE(a, b, ...) | COALESCE / IFNULL | 첫 번째 NOT NULL 값 |
| NULLIF(a, b) | NULLIF | a=b이면 NULL |

```sql
SELECT COALESCE(dept, '미배정') FROM employees;
SELECT NULLIF(salary, 0);  -- 0이면 NULL 반환
```

> PostgreSQL에는 MySQL의 `IFNULL`이나 Oracle의 `NVL`이 없습니다. `COALESCE`를 사용합니다.

---

## 조건 함수
```sql
-- CASE (표준 SQL)
SELECT name, CASE WHEN salary >= 5000000 THEN '고연봉' ELSE '일반' END FROM employees;

-- PostgreSQL에는 MySQL의 IF() 함수가 없습니다. CASE를 사용합니다.
```

---

## 타입 변환

```sql
-- CAST (표준)
SELECT CAST('123' AS INTEGER);
SELECT CAST('2026-05-04' AS DATE);

-- :: 연산자 (PostgreSQL 전용, 더 간결)
SELECT '123'::INTEGER;
SELECT '2026-05-04'::DATE;
SELECT 3.14::TEXT;
SELECT salary::INTEGER FROM employees;
```

---

## 윈도우 함수

```sql
-- ROW_NUMBER
SELECT name, dept_id, salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS 순위
FROM employees;

-- RANK / DENSE_RANK
SELECT name, salary,
    RANK() OVER (ORDER BY salary DESC) AS rank_순위,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_순위
FROM employees;

-- 부서별 급여 순위
SELECT name, dept_id, salary,
    ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS 부서내순위
FROM employees;

-- LAG / LEAD
SELECT name, salary,
    LAG(salary) OVER (ORDER BY salary) AS 이전급여,
    LEAD(salary) OVER (ORDER BY salary) AS 다음급여
FROM employees;

-- 누적 합계
SELECT name, salary,
    SUM(salary) OVER (ORDER BY hire_date) AS 누적급여
FROM employees;

-- FIRST_VALUE / LAST_VALUE
SELECT name, dept_id, salary,
    FIRST_VALUE(name) OVER (PARTITION BY dept_id ORDER BY salary DESC) AS 부서최고연봉자
FROM employees;

-- NTILE
SELECT name, salary,
    NTILE(4) OVER (ORDER BY salary DESC) AS 분위
FROM employees;
```

{% assign c-category = 'postgresql' %}
{% assign c-tag = 'lecture-postgresql' %}
{% include /custom-ref.html %}

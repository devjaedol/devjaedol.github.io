---
title: "[MySQL] 06. 내장 함수 정리"
categories: 
    - mysql
tags: 
    [mysql, mariadb, mysql강좌, 중급, 'lecture-mysql']
toc : true
toc_sticky  : true    
---

MySQL/MariaDB에서 자주 사용하는 내장 함수를 카테고리별로 정리합니다.

# 문자열 함수

| 함수 | 설명 | 예시 | 결과 |
|------|------|------|------|
| CONCAT | 문자열 연결 | `CONCAT('Hello', ' ', 'World')` | Hello World |
| CONCAT_WS | 구분자로 연결 | `CONCAT_WS('-', '2024', '01', '15')` | 2024-01-15 |
| SUBSTRING | 부분 문자열 | `SUBSTRING('Hello', 1, 3)` | Hel |
| LEFT / RIGHT | 왼쪽/오른쪽 n자 | `LEFT('Hello', 2)` | He |
| LENGTH | 바이트 길이 | `LENGTH('가나다')` | 9 (UTF-8) |
| CHAR_LENGTH | 문자 길이 | `CHAR_LENGTH('가나다')` | 3 |
| UPPER / LOWER | 대/소문자 변환 | `UPPER('hello')` | HELLO |
| TRIM | 양쪽 공백 제거 | `TRIM('  hi  ')` | hi |
| LTRIM / RTRIM | 왼쪽/오른쪽 공백 제거 | `LTRIM('  hi')` | hi |
| REPLACE | 문자열 치환 | `REPLACE('abc', 'b', 'x')` | axc |
| LPAD / RPAD | 왼쪽/오른쪽 패딩 | `LPAD('5', 3, '0')` | 005 |
| REVERSE | 문자열 뒤집기 | `REVERSE('abc')` | cba |
| INSTR | 위치 찾기 | `INSTR('Hello', 'lo')` | 4 |
| FORMAT | 숫자 포맷 | `FORMAT(1234567.89, 2)` | 1,234,567.89 |

```sql
-- 실전 예시: 이메일에서 도메인 추출
SELECT 
    email,
    SUBSTRING(email, INSTR(email, '@') + 1) AS domain
FROM users;

-- 이름 마스킹
SELECT CONCAT(LEFT(name, 1), '**') AS masked_name FROM employees;
-- 홍** , 김** , 이**
```

---

## 숫자 함수

| 함수 | 설명 | 예시 | 결과 |
|------|------|------|------|
| ROUND | 반올림 | `ROUND(3.456, 2)` | 3.46 |
| CEIL / CEILING | 올림 | `CEIL(3.1)` | 4 |
| FLOOR | 내림 | `FLOOR(3.9)` | 3 |
| TRUNCATE | 절삭 | `TRUNCATE(3.456, 2)` | 3.45 |
| ABS | 절대값 | `ABS(-5)` | 5 |
| MOD | 나머지 | `MOD(10, 3)` | 1 |
| POWER | 거듭제곱 | `POWER(2, 10)` | 1024 |
| SQRT | 제곱근 | `SQRT(16)` | 4 |
| RAND | 난수 (0~1) | `RAND()` | 0.7342... |

```sql
-- 실전 예시: 급여를 만원 단위로 반올림
SELECT name, ROUND(salary, -4) AS rounded_salary FROM employees;

-- 랜덤 정렬 (무작위 추출)
SELECT * FROM employees ORDER BY RAND() LIMIT 3;
```

---

## 날짜/시간 함수

| 함수 | 설명 | 예시 | 결과 |
|------|------|------|------|
| NOW() | 현재 날짜+시간 | `NOW()` | 2026-05-04 14:30:00 |
| CURDATE() | 현재 날짜 | `CURDATE()` | 2026-05-04 |
| CURTIME() | 현재 시간 | `CURTIME()` | 14:30:00 |
| DATE() | 날짜 부분 추출 | `DATE(NOW())` | 2026-05-04 |
| YEAR / MONTH / DAY | 연/월/일 추출 | `YEAR(NOW())` | 2026 |
| HOUR / MINUTE / SECOND | 시/분/초 추출 | `HOUR(NOW())` | 14 |
| DATE_ADD | 날짜 더하기 | `DATE_ADD(NOW(), INTERVAL 7 DAY)` | +7일 |
| DATE_SUB | 날짜 빼기 | `DATE_SUB(NOW(), INTERVAL 1 MONTH)` | -1개월 |
| DATEDIFF | 날짜 차이 (일) | `DATEDIFF('2026-12-31', '2026-01-01')` | 364 |
| TIMESTAMPDIFF | 단위별 차이 | `TIMESTAMPDIFF(MONTH, '2024-01-01', '2026-05-04')` | 28 |
| DATE_FORMAT | 날짜 포맷 | `DATE_FORMAT(NOW(), '%Y년 %m월 %d일')` | 2026년 05월 04일 |
| STR_TO_DATE | 문자→날짜 변환 | `STR_TO_DATE('2026-05-04', '%Y-%m-%d')` | 2026-05-04 |
| LAST_DAY | 해당 월 마지막 날 | `LAST_DAY('2026-02-01')` | 2026-02-28 |
| DAYOFWEEK | 요일 (1=일, 7=토) | `DAYOFWEEK('2026-05-04')` | 2 (월) |

### DATE_FORMAT 주요 포맷 코드

| 코드 | 설명 | 예시 |
|------|------|------|
| %Y | 4자리 연도 | 2026 |
| %y | 2자리 연도 | 26 |
| %m | 월 (01~12) | 05 |
| %d | 일 (01~31) | 04 |
| %H | 시 (00~23) | 14 |
| %i | 분 (00~59) | 30 |
| %s | 초 (00~59) | 00 |
| %W | 요일 이름 | Monday |

```sql
-- 실전 예시: 입사 후 근속 연수 계산
SELECT 
    name,
    hire_date,
    TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS 근속연수
FROM employees;

-- 이번 달 입사자 조회
SELECT * FROM employees
WHERE DATE_FORMAT(hire_date, '%Y-%m') = DATE_FORMAT(NOW(), '%Y-%m');
```

---

## 조건 함수

```sql
-- IF: 조건에 따라 값 반환
SELECT name, IF(salary >= 5000000, '고연봉', '일반') AS 구분
FROM employees;

-- IFNULL: NULL이면 대체값 반환
SELECT name, IFNULL(dept_id, '미배정') AS 부서 FROM employees;

-- NULLIF: 두 값이 같으면 NULL 반환
SELECT NULLIF(10, 10);  -- NULL
SELECT NULLIF(10, 20);  -- 10

-- COALESCE: 첫 번째 NOT NULL 값 반환
SELECT COALESCE(NULL, NULL, '기본값', 'abc');  -- '기본값'
```

---

## 변환 함수

```sql
-- 타입 변환
SELECT CAST('123' AS SIGNED);          -- 정수로 변환
SELECT CAST('2026-05-04' AS DATE);     -- 날짜로 변환
SELECT CAST(3.14 AS CHAR);            -- 문자로 변환

SELECT CONVERT('123', SIGNED);         -- CAST와 동일
SELECT CONVERT('abc' USING utf8mb4);   -- 문자셋 변환
```

---

## 윈도우 함수 (MySQL 8.0+)
집계 함수와 달리 행을 그룹으로 축소하지 않고, 각 행에 대해 계산 결과를 반환합니다.

```sql
-- ROW_NUMBER: 순번 부여
SELECT 
    name, dept_id, salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS 순위
FROM employees;

-- RANK: 동일 값은 같은 순위 (다음 순위 건너뜀)
SELECT 
    name, salary,
    RANK() OVER (ORDER BY salary DESC) AS 순위
FROM employees;

-- DENSE_RANK: 동일 값은 같은 순위 (다음 순위 연속)
SELECT 
    name, salary,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS 순위
FROM employees;

-- 부서별 급여 순위
SELECT 
    name, dept_id, salary,
    ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS 부서내순위
FROM employees;

-- LAG / LEAD: 이전/다음 행 값 참조
SELECT 
    name, salary,
    LAG(salary, 1) OVER (ORDER BY salary) AS 이전급여,
    LEAD(salary, 1) OVER (ORDER BY salary) AS 다음급여
FROM employees;

-- SUM OVER: 누적 합계
SELECT 
    name, salary,
    SUM(salary) OVER (ORDER BY hire_date) AS 누적급여
FROM employees;
```

{% assign c-category = 'mysql' %}
{% assign c-tag = 'lecture-mysql' %}
{% include /custom-ref.html %}

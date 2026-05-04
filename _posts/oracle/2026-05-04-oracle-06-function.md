---
title: "[Oracle] 06. 내장 함수 정리"
categories: 
    - oracle
tags: 
    [oracle, oracle강좌, 중급, 'lecture-oracle']
toc : true
toc_sticky  : true    
---

Oracle에서 자주 사용하는 내장 함수를 카테고리별로 정리합니다.    
MySQL 대응 함수도 함께 표기합니다.

# 문자열 함수

| Oracle 함수 | MySQL 대응 | 설명 | 예시 | 결과 |
|------------|-----------|------|------|------|
| `\|\|` (연결 연산자) | CONCAT | 문자열 연결 | `'Hello' \|\| ' ' \|\| 'World'` | Hello World |
| CONCAT | CONCAT | 2개 문자열 연결 | `CONCAT('A', 'B')` | AB |
| SUBSTR | SUBSTRING | 부분 문자열 | `SUBSTR('Hello', 1, 3)` | Hel |
| LENGTH | CHAR_LENGTH | 문자 길이 | `LENGTH('가나다')` | 3 |
| LENGTHB | LENGTH | 바이트 길이 | `LENGTHB('가나다')` | 9 |
| UPPER / LOWER | UPPER / LOWER | 대/소문자 | `UPPER('hello')` | HELLO |
| INITCAP | 없음 | 첫 글자 대문자 | `INITCAP('hello world')` | Hello World |
| TRIM | TRIM | 공백 제거 | `TRIM('  hi  ')` | hi |
| LTRIM / RTRIM | LTRIM / RTRIM | 좌/우 공백 제거 | `LTRIM('  hi')` | hi |
| REPLACE | REPLACE | 문자열 치환 | `REPLACE('abc', 'b', 'x')` | axc |
| LPAD / RPAD | LPAD / RPAD | 패딩 | `LPAD('5', 3, '0')` | 005 |
| REVERSE | REVERSE | 뒤집기 | `REVERSE('abc')` | cba |
| INSTR | INSTR | 위치 찾기 | `INSTR('Hello', 'lo')` | 4 |
| TRANSLATE | 없음 | 문자 단위 치환 | `TRANSLATE('abc', 'abc', 'xyz')` | xyz |
| REGEXP_SUBSTR | REGEXP_SUBSTR | 정규식 추출 | 아래 예시 참고 | |

```sql
-- Oracle은 || 연산자로 문자열을 연결합니다 (MySQL은 CONCAT)
SELECT '이름: ' || name || ', 부서: ' || dept FROM employees;

-- INITCAP: Oracle 전용
SELECT INITCAP('hello world oracle') FROM DUAL;  -- Hello World Oracle

-- TRANSLATE: 문자 단위 1:1 치환
SELECT TRANSLATE('010-1234-5678', '0123456789', '##########') FROM DUAL;
-- ###-####-####

-- 정규식 함수
SELECT REGEXP_SUBSTR('test@email.com', '[^@]+', 1, 2) FROM DUAL;  -- email.com
SELECT REGEXP_REPLACE('010-1234-5678', '[^0-9]', '') FROM DUAL;   -- 01012345678
SELECT REGEXP_COUNT('aababc', 'ab') FROM DUAL;                     -- 2
```

---

## 숫자 함수

| Oracle 함수 | MySQL 대응 | 설명 | 예시 | 결과 |
|------------|-----------|------|------|------|
| ROUND | ROUND | 반올림 | `ROUND(3.456, 2)` | 3.46 |
| CEIL | CEIL | 올림 | `CEIL(3.1)` | 4 |
| FLOOR | FLOOR | 내림 | `FLOOR(3.9)` | 3 |
| TRUNC | TRUNCATE | 절삭 | `TRUNC(3.456, 2)` | 3.45 |
| ABS | ABS | 절대값 | `ABS(-5)` | 5 |
| MOD | MOD | 나머지 | `MOD(10, 3)` | 1 |
| POWER | POWER | 거듭제곱 | `POWER(2, 10)` | 1024 |
| SQRT | SQRT | 제곱근 | `SQRT(16)` | 4 |
| SIGN | SIGN | 부호 | `SIGN(-5)` | -1 |
| DBMS_RANDOM.VALUE | RAND | 난수 | `DBMS_RANDOM.VALUE(1, 100)` | 1~100 |

```sql
-- TRUNC: 날짜에도 사용 가능 (Oracle 특유)
SELECT TRUNC(SYSDATE) FROM DUAL;           -- 시간 제거 (00:00:00)
SELECT TRUNC(SYSDATE, 'MM') FROM DUAL;     -- 해당 월 1일
SELECT TRUNC(SYSDATE, 'YYYY') FROM DUAL;   -- 해당 연도 1월 1일

-- 랜덤 정렬
SELECT * FROM employees ORDER BY DBMS_RANDOM.VALUE;
```

---

## 날짜/시간 함수

| Oracle 함수 | MySQL 대응 | 설명 |
|------------|-----------|------|
| SYSDATE | NOW() | 현재 날짜+시간 |
| SYSTIMESTAMP | NOW(6) | 현재 타임스탬프 (밀리초) |
| CURRENT_DATE | CURDATE() | 세션 시간대 기준 현재 날짜 |
| TRUNC(SYSDATE) | CURDATE() | 시간 제거한 날짜 |
| ADD_MONTHS | DATE_ADD | 월 더하기 |
| MONTHS_BETWEEN | TIMESTAMPDIFF | 월 차이 |
| LAST_DAY | LAST_DAY | 해당 월 마지막 날 |
| NEXT_DAY | 없음 | 다음 특정 요일 |
| EXTRACT | EXTRACT | 연/월/일 추출 |
| TO_CHAR | DATE_FORMAT | 날짜 포맷 |
| TO_DATE | STR_TO_DATE | 문자→날짜 변환 |

```sql
-- 현재 날짜/시간
SELECT SYSDATE FROM DUAL;              -- 2026-05-04 14:30:00
SELECT SYSTIMESTAMP FROM DUAL;         -- 2026-05-04 14:30:00.123456 +09:00

-- 날짜 연산 (Oracle은 날짜에 숫자를 직접 더할 수 있음)
SELECT SYSDATE + 7 FROM DUAL;          -- 7일 후
SELECT SYSDATE - 30 FROM DUAL;         -- 30일 전
SELECT SYSDATE + 1/24 FROM DUAL;       -- 1시간 후
SELECT SYSDATE + 1/24/60 FROM DUAL;    -- 1분 후

-- ADD_MONTHS
SELECT ADD_MONTHS(SYSDATE, 3) FROM DUAL;   -- 3개월 후
SELECT ADD_MONTHS(SYSDATE, -6) FROM DUAL;  -- 6개월 전

-- MONTHS_BETWEEN
SELECT MONTHS_BETWEEN(SYSDATE, TO_DATE('2024-01-01', 'YYYY-MM-DD')) FROM DUAL;

-- EXTRACT
SELECT EXTRACT(YEAR FROM SYSDATE) FROM DUAL;   -- 2026
SELECT EXTRACT(MONTH FROM SYSDATE) FROM DUAL;  -- 5
SELECT EXTRACT(DAY FROM SYSDATE) FROM DUAL;    -- 4

-- LAST_DAY
SELECT LAST_DAY(SYSDATE) FROM DUAL;  -- 2026-05-31

-- NEXT_DAY (Oracle 전용)
SELECT NEXT_DAY(SYSDATE, '월요일') FROM DUAL;  -- 다음 월요일
```

### TO_CHAR / TO_DATE 포맷

| 포맷 | 설명 | 예시 |
|------|------|------|
| YYYY | 4자리 연도 | 2026 |
| MM | 월 (01~12) | 05 |
| DD | 일 (01~31) | 04 |
| HH24 | 시 (00~23) | 14 |
| MI | 분 (00~59) | 30 |
| SS | 초 (00~59) | 00 |
| DAY | 요일 이름 | 월요일 |
| DY | 요일 약어 | 월 |
| Q | 분기 | 2 |
| WW | 주차 | 18 |

```sql
-- 날짜 → 문자열
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'YYYY"년" MM"월" DD"일"') FROM DUAL;  -- 2026년 05월 04일

-- 문자열 → 날짜
SELECT TO_DATE('2026-05-04', 'YYYY-MM-DD') FROM DUAL;
SELECT TO_DATE('20260504143000', 'YYYYMMDDHH24MISS') FROM DUAL;

-- 숫자 포맷
SELECT TO_CHAR(1234567.89, '9,999,999.99') FROM DUAL;  -- 1,234,567.89
SELECT TO_CHAR(salary, 'L999,999,999') FROM employees;  -- ₩5,000,000

-- 입사 후 근속 연수
SELECT 
    name,
    hire_date,
    TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) AS 근속연수
FROM employees;
```

---

## NULL 처리 함수

| Oracle 함수 | MySQL 대응 | 설명 |
|------------|-----------|------|
| NVL(a, b) | IFNULL(a, b) | a가 NULL이면 b 반환 |
| NVL2(a, b, c) | IF(a IS NOT NULL, b, c) | a가 NOT NULL이면 b, NULL이면 c |
| NULLIF(a, b) | NULLIF(a, b) | a=b이면 NULL, 아니면 a |
| COALESCE(a, b, ...) | COALESCE(a, b, ...) | 첫 번째 NOT NULL 값 |

```sql
SELECT NVL(dept, '미배정') FROM employees;
SELECT NVL2(dept, '배정됨', '미배정') FROM employees;
SELECT COALESCE(dept, '미배정') FROM employees;
```

---

## 변환 함수

```sql
-- 문자 → 숫자
SELECT TO_NUMBER('12345') FROM DUAL;
SELECT TO_NUMBER('1,234.56', '9,999.99') FROM DUAL;

-- 숫자 → 문자
SELECT TO_CHAR(12345, '99,999') FROM DUAL;

-- 암묵적 변환 주의
-- ❌ 인덱스 무효화 가능
SELECT * FROM employees WHERE id = '1';  -- NUMBER 컬럼에 문자열 비교
-- ✅ 올바른 타입 사용
SELECT * FROM employees WHERE id = 1;
```

---

## 윈도우 함수 (Analytic Functions)

Oracle은 윈도우 함수를 가장 먼저 도입한 DBMS 중 하나입니다.

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
    LAG(salary, 1) OVER (ORDER BY salary) AS 이전급여,
    LEAD(salary, 1) OVER (ORDER BY salary) AS 다음급여
FROM employees;

-- 누적 합계
SELECT name, salary,
    SUM(salary) OVER (ORDER BY hire_date) AS 누적급여
FROM employees;

-- FIRST_VALUE / LAST_VALUE
SELECT name, dept_id, salary,
    FIRST_VALUE(name) OVER (PARTITION BY dept_id ORDER BY salary DESC) AS 부서최고연봉자
FROM employees;

-- NTILE: 균등 분할
SELECT name, salary,
    NTILE(4) OVER (ORDER BY salary DESC) AS 분위
FROM employees;

-- RATIO_TO_REPORT: 비율 계산
SELECT name, salary,
    ROUND(RATIO_TO_REPORT(salary) OVER () * 100, 1) AS 급여비율
FROM employees;
```

{% assign c-category = 'oracle' %}
{% assign c-tag = 'lecture-oracle' %}
{% include /custom-ref.html %}

---
title: "[PostgreSQL] 03. CRUD 기본 (INSERT, SELECT, UPDATE, DELETE)"
categories: 
    - postgresql
tags: 
    [postgresql, postgres, postgresql강좌, 초급, 'lecture-postgresql']
toc : true
toc_sticky  : true    
---

PostgreSQL에서의 데이터 조작 기본인 CRUD 명령어를 정리합니다.

# 샘플 테이블 준비

```sql
CREATE TABLE employees (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(50) NOT NULL,
    dept       VARCHAR(30),
    salary     NUMERIC(12,2) DEFAULT 0,
    hire_date  DATE
);
```

---

## INSERT (데이터 삽입)

### 기본 삽입
```sql
-- 단일 행 삽입
INSERT INTO employees (name, dept, salary, hire_date)
VALUES ('홍길동', '개발팀', 5000000, '2024-01-15');

-- 여러 행 한번에 삽입
INSERT INTO employees (name, dept, salary, hire_date) VALUES
('김철수', '기획팀', 4500000, '2024-02-01'),
('이영희', '개발팀', 5500000, '2023-06-10'),
('박민수', '디자인팀', 4800000, '2024-03-20'),
('최지은', '개발팀', 6000000, '2022-11-05');
```

### INSERT 변형
```sql
-- RETURNING: 삽입된 데이터 즉시 반환 (PostgreSQL 전용)
INSERT INTO employees (name, dept, salary)
VALUES ('정수진', '인사팀', 4700000)
RETURNING id, name;

-- 충돌 시 처리 (ON CONFLICT = MySQL의 ON DUPLICATE KEY UPDATE)
INSERT INTO employees (id, name, dept, salary)
VALUES (1, '홍길동', '인사팀', 5500000)
ON CONFLICT (id) DO UPDATE
SET dept = EXCLUDED.dept, salary = EXCLUDED.salary;

-- 충돌 시 무시
INSERT INTO employees (id, name, dept, salary)
VALUES (1, '홍길동', '인사팀', 5500000)
ON CONFLICT (id) DO NOTHING;

-- 다른 테이블에서 복사
INSERT INTO employees_backup
SELECT * FROM employees WHERE dept = '개발팀';
```

> `RETURNING` 절은 PostgreSQL의 강력한 기능으로, INSERT/UPDATE/DELETE 후 결과를 바로 받을 수 있습니다.

---

## SELECT (데이터 조회)

### 기본 조회
```sql
SELECT * FROM employees;
SELECT name, dept, salary FROM employees;
SELECT name AS "이름", dept AS "부서", salary AS "급여" FROM employees;
SELECT DISTINCT dept FROM employees;
```

### WHERE 조건절
```sql
SELECT * FROM employees WHERE salary >= 5000000;
SELECT * FROM employees WHERE dept = '개발팀';
SELECT * FROM employees WHERE dept != '기획팀';

SELECT * FROM employees WHERE dept = '개발팀' AND salary >= 5000000;
SELECT * FROM employees WHERE dept = '개발팀' OR dept = '기획팀';

SELECT * FROM employees WHERE salary BETWEEN 4500000 AND 5500000;
SELECT * FROM employees WHERE dept IN ('개발팀', '기획팀');

-- LIKE / ILIKE (대소문자 무시)
SELECT * FROM employees WHERE name LIKE '김%';
SELECT * FROM employees WHERE name ILIKE 'hong%';  -- PostgreSQL 전용

-- NULL 체크
SELECT * FROM employees WHERE dept IS NULL;
SELECT * FROM employees WHERE dept IS NOT NULL;
```

### 정렬 (ORDER BY)
```sql
SELECT * FROM employees ORDER BY salary ASC;
SELECT * FROM employees ORDER BY salary DESC;
SELECT * FROM employees ORDER BY dept ASC, salary DESC;

-- NULLS FIRST / NULLS LAST
SELECT * FROM employees ORDER BY dept NULLS LAST;
```

### 행 수 제한 (LIMIT / OFFSET)
```sql
-- 상위 3건
SELECT * FROM employees ORDER BY salary DESC LIMIT 3;

-- 페이징: 3번째부터 3건
SELECT * FROM employees ORDER BY id LIMIT 3 OFFSET 2;

-- 표준 SQL 방식 (PostgreSQL 13+)
SELECT * FROM employees ORDER BY salary DESC
FETCH FIRST 3 ROWS ONLY;

SELECT * FROM employees ORDER BY id
OFFSET 2 ROWS FETCH NEXT 3 ROWS ONLY;
```

---

## UPDATE (데이터 수정)

```sql
UPDATE employees SET salary = 5200000 WHERE id = 1;
UPDATE employees SET dept = '인사팀', salary = 5300000 WHERE id = 1;
UPDATE employees SET salary = salary * 1.1 WHERE dept = '개발팀';

-- RETURNING: 수정된 데이터 반환
UPDATE employees SET salary = salary * 1.1
WHERE dept = '개발팀'
RETURNING id, name, salary;

-- FROM 절을 이용한 JOIN UPDATE (PostgreSQL 전용)
UPDATE employees e
SET salary = d.base_salary
FROM departments d
WHERE e.dept_id = d.id AND d.name = '개발팀';
```

---

## DELETE (데이터 삭제)

```sql
DELETE FROM employees WHERE id = 5;
DELETE FROM employees WHERE dept = '기획팀' AND salary < 4000000;

-- RETURNING: 삭제된 데이터 반환
DELETE FROM employees WHERE id = 5 RETURNING *;

-- USING 절을 이용한 JOIN DELETE (PostgreSQL 전용)
DELETE FROM employees e
USING departments d
WHERE e.dept_id = d.id AND d.name = '폐지부서';

-- 전체 삭제
DELETE FROM employees;
TRUNCATE TABLE employees RESTART IDENTITY;
```

---

## 집계 함수

```sql
SELECT COUNT(*) FROM employees;
SELECT COUNT(DISTINCT dept) FROM employees;

SELECT SUM(salary) AS 총급여 FROM employees;
SELECT AVG(salary) AS 평균급여 FROM employees;
SELECT MAX(salary) AS 최고급여 FROM employees;
SELECT MIN(salary) AS 최저급여 FROM employees;

-- 부서별 집계
SELECT dept, COUNT(*) AS 인원, ROUND(AVG(salary), 0) AS 평균급여
FROM employees
GROUP BY dept;

-- HAVING
SELECT dept, AVG(salary) AS avg_sal
FROM employees
GROUP BY dept
HAVING AVG(salary) >= 5000000;

-- FILTER (PostgreSQL 전용, 조건부 집계)
SELECT
    COUNT(*) AS 전체,
    COUNT(*) FILTER (WHERE salary >= 5000000) AS 고연봉,
    COUNT(*) FILTER (WHERE salary < 5000000) AS 일반
FROM employees;
```

### SELECT 실행 순서

```text
FROM → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT/OFFSET
```

{% assign c-category = 'postgresql' %}
{% assign c-tag = 'lecture-postgresql' %}
{% include /custom-ref.html %}

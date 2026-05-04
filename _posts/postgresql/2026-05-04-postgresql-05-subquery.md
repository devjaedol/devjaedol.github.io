---
title: "[PostgreSQL] 05. 서브쿼리와 고급 SELECT"
categories: 
    - postgresql
tags: 
    [postgresql, postgres, postgresql강좌, 중급, 'lecture-postgresql']
toc : true
toc_sticky  : true    
---

PostgreSQL의 서브쿼리, CTE, UNION, 윈도우 함수 등 고급 SELECT 기법을 정리합니다.

# 서브쿼리

## 스칼라 서브쿼리 (SELECT 절)
```sql
SELECT
    name, salary,
    (SELECT AVG(salary) FROM employees) AS 평균급여,
    salary - (SELECT AVG(salary) FROM employees) AS 차이
FROM employees;
```

## 중첩 서브쿼리 (WHERE 절)
```sql
-- 단일 행
SELECT name, salary FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);

-- IN
SELECT name, salary FROM employees
WHERE dept_id IN (SELECT id FROM departments WHERE name = '개발팀');

-- EXISTS
SELECT d.name FROM departments d
WHERE EXISTS (SELECT 1 FROM employees e WHERE e.dept_id = d.id);

-- NOT EXISTS
SELECT d.name FROM departments d
WHERE NOT EXISTS (SELECT 1 FROM employees e WHERE e.dept_id = d.id);

-- ANY / ALL
SELECT name, salary FROM employees
WHERE salary > ALL (SELECT salary FROM employees WHERE dept_id = 2);
```

## 인라인 뷰 (FROM 절)
```sql
SELECT dept_name, avg_salary
FROM (
    SELECT d.name AS dept_name, AVG(e.salary) AS avg_salary
    FROM employees e
    JOIN departments d ON e.dept_id = d.id
    GROUP BY d.name
) AS dept_avg
WHERE avg_salary >= 5000000;
```

---

## WITH (CTE - Common Table Expression)

### 기본 CTE
```sql
WITH dept_salary AS (
    SELECT d.name AS dept_name, AVG(e.salary) AS avg_salary
    FROM employees e
    JOIN departments d ON e.dept_id = d.id
    GROUP BY d.name
)
SELECT dept_name, avg_salary
FROM dept_salary
WHERE avg_salary >= 5000000;
```

### 다중 CTE
```sql
WITH
high_salary AS (
    SELECT * FROM employees WHERE salary >= 5500000
),
dev_team AS (
    SELECT * FROM employees WHERE dept_id = 1
)
SELECT h.name FROM high_salary h
JOIN dev_team d ON h.id = d.id;
```

### 재귀 CTE
```sql
WITH RECURSIVE org_tree AS (
    -- 기본 케이스
    SELECT id, name, manager_id, 1 AS depth
    FROM staff
    WHERE manager_id IS NULL

    UNION ALL

    -- 재귀 케이스
    SELECT s.id, s.name, s.manager_id, t.depth + 1
    FROM staff s
    JOIN org_tree t ON s.manager_id = t.id
)
SELECT REPEAT('  ', depth - 1) || name AS 조직도, depth AS 레벨
FROM org_tree
ORDER BY depth, id;
```

### CTE를 이용한 DML (PostgreSQL 전용)
```sql
-- CTE에서 DELETE 후 결과를 INSERT
WITH deleted AS (
    DELETE FROM employees
    WHERE hire_date < '2020-01-01'
    RETURNING *
)
INSERT INTO employees_archive
SELECT * FROM deleted;
```

---

## CASE 표현식
```sql
SELECT
    name, salary,
    CASE
        WHEN salary >= 6000000 THEN '고급'
        WHEN salary >= 5000000 THEN '중급'
        ELSE '초급'
    END AS 등급
FROM employees;
```

---

## UNION / INTERSECT / EXCEPT

```sql
-- UNION: 합집합 (중복 제거)
SELECT name FROM employees WHERE dept_id = 1
UNION
SELECT name FROM employees WHERE salary >= 5000000;

-- UNION ALL: 합집합 (중복 허용)
SELECT name FROM employees WHERE dept_id = 1
UNION ALL
SELECT name FROM employees WHERE salary >= 5000000;

-- INTERSECT: 교집합
SELECT dept_id FROM departments
INTERSECT
SELECT DISTINCT dept_id FROM employees WHERE dept_id IS NOT NULL;

-- EXCEPT: 차집합 (MySQL의 MINUS에 해당하지만 Oracle과 키워드가 다름)
SELECT id FROM departments
EXCEPT
SELECT DISTINCT dept_id FROM employees WHERE dept_id IS NOT NULL;
```

---

## GROUPING SETS / ROLLUP / CUBE (PostgreSQL 9.5+)

```sql
-- GROUPING SETS: 여러 그룹핑을 한 번에
SELECT dept, hire_date, SUM(salary)
FROM employees
GROUP BY GROUPING SETS ((dept), (hire_date), ());

-- ROLLUP: 계층적 소계
SELECT dept, COUNT(*), SUM(salary)
FROM employees
GROUP BY ROLLUP (dept);

-- CUBE: 모든 조합의 소계
SELECT dept, is_active, COUNT(*), SUM(salary)
FROM employees
GROUP BY CUBE (dept, is_active);
```

{% assign c-category = 'postgresql' %}
{% assign c-tag = 'lecture-postgresql' %}
{% include /custom-ref.html %}

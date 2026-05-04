---
title: "[MySQL] 05. 서브쿼리와 고급 SELECT"
categories: 
    - mysql
tags: 
    [mysql, mariadb, mysql강좌, 중급, 'lecture-mysql']
toc : true
toc_sticky  : true    
---

서브쿼리(Subquery)와 다양한 고급 SELECT 기법을 정리합니다.

# 서브쿼리란?
쿼리 안에 포함된 또 다른 쿼리를 서브쿼리(Subquery)라고 합니다.    
사용 위치에 따라 스칼라, 인라인 뷰, 중첩 서브쿼리로 구분합니다.

---

## 스칼라 서브쿼리 (SELECT 절)
단일 값을 반환하는 서브쿼리로, SELECT 절에서 사용합니다.
```sql
SELECT 
    name,
    salary,
    (SELECT AVG(salary) FROM employees) AS 평균급여,
    salary - (SELECT AVG(salary) FROM employees) AS 차이
FROM employees;
```

---

## 중첩 서브쿼리 (WHERE 절)

### 단일 행 서브쿼리
```sql
-- 가장 높은 급여를 받는 직원
SELECT name, salary
FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);
```

### 다중 행 서브쿼리 (IN, ANY, ALL)
```sql
-- 개발팀에 속한 직원 조회
SELECT name, salary
FROM employees
WHERE dept_id IN (SELECT id FROM departments WHERE name = '개발팀');

-- ANY: 서브쿼리 결과 중 하나라도 만족
SELECT name, salary
FROM employees
WHERE salary > ANY (SELECT salary FROM employees WHERE dept_id = 2);

-- ALL: 서브쿼리 결과 모두 만족
SELECT name, salary
FROM employees
WHERE salary > ALL (SELECT salary FROM employees WHERE dept_id = 2);
```

### EXISTS / NOT EXISTS
```sql
-- 직원이 있는 부서만 조회
SELECT d.name
FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.dept_id = d.id
);

-- 직원이 없는 부서 조회
SELECT d.name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1 FROM employees e WHERE e.dept_id = d.id
);
```

---

## 인라인 뷰 (FROM 절)
FROM 절에 서브쿼리를 사용하여 임시 테이블처럼 활용합니다.
```sql
-- 부서별 평균 급여가 500만 이상인 부서
SELECT dept_name, avg_salary
FROM (
    SELECT d.name AS dept_name, AVG(e.salary) AS avg_salary
    FROM employees e
    INNER JOIN departments d ON e.dept_id = d.id
    GROUP BY d.name
) AS dept_avg
WHERE avg_salary >= 5000000;
```

---

## CASE 표현식
조건에 따라 다른 값을 반환합니다.
```sql
SELECT 
    name,
    salary,
    CASE
        WHEN salary >= 6000000 THEN '고급'
        WHEN salary >= 5000000 THEN '중급'
        ELSE '초급'
    END AS 등급
FROM employees;

-- 집계와 함께 사용 (피벗 형태)
SELECT 
    dept_id,
    SUM(CASE WHEN salary >= 5000000 THEN 1 ELSE 0 END) AS '500만이상',
    SUM(CASE WHEN salary < 5000000 THEN 1 ELSE 0 END) AS '500만미만'
FROM employees
GROUP BY dept_id;
```

---

## UNION / UNION ALL
여러 SELECT 결과를 합칩니다.
```sql
-- UNION: 중복 제거
SELECT name, '직원' AS 구분 FROM employees
UNION
SELECT name, '부서' AS 구분 FROM departments;

-- UNION ALL: 중복 허용 (더 빠름)
SELECT name FROM employees WHERE dept_id = 1
UNION ALL
SELECT name FROM employees WHERE salary >= 5000000;
```

UNION 규칙:
- 각 SELECT의 컬럼 수가 동일해야 합니다
- 대응하는 컬럼의 데이터 타입이 호환되어야 합니다
- ORDER BY는 마지막 SELECT에만 사용 가능합니다

---

## WITH (CTE - Common Table Expression)
MySQL 8.0+ 에서 사용 가능한 CTE는 복잡한 쿼리를 가독성 있게 작성할 수 있습니다.
```sql
-- 기본 CTE
WITH dept_salary AS (
    SELECT d.name AS dept_name, AVG(e.salary) AS avg_salary
    FROM employees e
    INNER JOIN departments d ON e.dept_id = d.id
    GROUP BY d.name
)
SELECT dept_name, avg_salary
FROM dept_salary
WHERE avg_salary >= 5000000;

-- 다중 CTE
WITH 
high_salary AS (
    SELECT * FROM employees WHERE salary >= 5500000
),
dev_team AS (
    SELECT * FROM employees WHERE dept_id = 1
)
SELECT h.name
FROM high_salary h
INNER JOIN dev_team d ON h.id = d.id;
```

### 재귀 CTE (계층 구조 조회)
```sql
-- 조직도 계층 조회
WITH RECURSIVE org_tree AS (
    -- 기본 케이스: 최상위 (manager_id IS NULL)
    SELECT id, name, manager_id, 1 AS depth
    FROM staff
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- 재귀 케이스
    SELECT s.id, s.name, s.manager_id, t.depth + 1
    FROM staff s
    INNER JOIN org_tree t ON s.manager_id = t.id
)
SELECT CONCAT(REPEAT('  ', depth - 1), name) AS 조직도, depth AS 레벨
FROM org_tree
ORDER BY depth, id;
```

```text
+----------+------+
| 조직도    | 레벨  |
+----------+------+
| 김대표    |    1 |
|   이부장  |    2 |
|     박과장 |    3 |
|       최사원|    4 |
+----------+------+
```

{% assign c-category = 'mysql' %}
{% assign c-tag = 'lecture-mysql' %}
{% include /custom-ref.html %}

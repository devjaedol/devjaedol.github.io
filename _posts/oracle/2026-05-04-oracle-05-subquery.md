---
title: "[Oracle] 05. 서브쿼리와 고급 SELECT"
categories: 
    - oracle
tags: 
    [oracle, oracle강좌, 중급, 'lecture-oracle']
toc : true
toc_sticky  : true    
---

Oracle에서의 서브쿼리, CASE, UNION, WITH(CTE), 계층형 쿼리를 정리합니다.

# 스칼라 서브쿼리 (SELECT 절)
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
SELECT name, salary
FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);
```

### 다중 행 서브쿼리 (IN, ANY, ALL)
```sql
-- IN
SELECT name, salary
FROM employees
WHERE dept_id IN (SELECT id FROM departments WHERE name = '개발팀');

-- ANY (= SOME)
SELECT name, salary
FROM employees
WHERE salary > ANY (SELECT salary FROM employees WHERE dept_id = 2);

-- ALL
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

-- 직원이 없는 부서
SELECT d.name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1 FROM employees e WHERE e.dept_id = d.id
);
```

---

## 인라인 뷰 (FROM 절)
```sql
SELECT dept_name, avg_salary
FROM (
    SELECT d.name AS dept_name, AVG(e.salary) AS avg_salary
    FROM employees e
    INNER JOIN departments d ON e.dept_id = d.id
    GROUP BY d.name
) dept_avg
WHERE avg_salary >= 5000000;
```

---

## CASE 표현식
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

-- DECODE (Oracle 전용, 간단한 등치 비교)
SELECT 
    name,
    dept_id,
    DECODE(dept_id, 1, '개발팀', 2, '기획팀', 3, '디자인팀', '기타') AS 부서명
FROM employees;
```

### CASE vs DECODE

| 항목 | CASE | DECODE |
|------|------|--------|
| 표준 | ANSI SQL 표준 | Oracle 전용 |
| 조건 | 범위, 비교, 복합 조건 가능 | 등치(=) 비교만 가능 |
| 가독성 | 좋음 | 인자가 많으면 나쁨 |
| 권장 | ✅ 권장 | 간단한 경우만 |

---

## UNION / UNION ALL
```sql
-- UNION: 중복 제거
SELECT name, '직원' AS 구분 FROM employees
UNION
SELECT name, '부서' AS 구분 FROM departments;

-- UNION ALL: 중복 허용 (더 빠름)
SELECT name FROM employees WHERE dept_id = 1
UNION ALL
SELECT name FROM employees WHERE salary >= 5000000;

-- MINUS: 차집합 (Oracle 전용, MySQL에는 없음)
SELECT dept_id FROM departments
MINUS
SELECT DISTINCT dept_id FROM employees WHERE dept_id IS NOT NULL;

-- INTERSECT: 교집합
SELECT dept_id FROM departments
INTERSECT
SELECT DISTINCT dept_id FROM employees WHERE dept_id IS NOT NULL;
```

> Oracle은 `MINUS`와 `INTERSECT`를 기본 지원합니다. MySQL에서는 서브쿼리로 구현해야 합니다.

---

## WITH (CTE - Common Table Expression)

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

### 재귀 CTE (Oracle 11gR2+)
```sql
WITH org_tree (id, name, manager_id, depth) AS (
    -- 기본 케이스
    SELECT id, name, manager_id, 1 AS depth
    FROM staff
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- 재귀 케이스
    SELECT s.id, s.name, s.manager_id, t.depth + 1
    FROM staff s
    INNER JOIN org_tree t ON s.manager_id = t.id
)
SELECT LPAD(' ', (depth - 1) * 2) || name AS 조직도, depth AS 레벨
FROM org_tree
ORDER BY depth, id;
```

---

## 계층형 쿼리 (CONNECT BY) - Oracle 전용

Oracle의 전통적인 계층형 쿼리 문법입니다. 재귀 CTE보다 간결합니다.

```sql
-- 기본 계층형 쿼리
SELECT 
    LEVEL AS 레벨,
    LPAD(' ', (LEVEL - 1) * 2) || name AS 조직도,
    id,
    manager_id
FROM staff
START WITH manager_id IS NULL        -- 루트 노드 조건
CONNECT BY PRIOR id = manager_id     -- 부모-자식 관계
ORDER SIBLINGS BY name;              -- 같은 레벨 내 정렬
```

```text
+------+----------+----+------------+
| 레벨  | 조직도    | ID | MANAGER_ID |
+------+----------+----+------------+
|    1 | 김대표    |  1 |     (null) |
|    2 |   이부장  |  2 |          1 |
|    3 |     박과장 |  3 |          2 |
|    4 |       최사원|  4 |          3 |
+------+----------+----+------------+
```

### 계층형 쿼리 주요 키워드

| 키워드 | 설명 |
|--------|------|
| `START WITH` | 루트 노드 조건 |
| `CONNECT BY PRIOR` | 부모-자식 관계 정의 |
| `LEVEL` | 현재 깊이 (1부터 시작) |
| `SYS_CONNECT_BY_PATH` | 루트부터 현재까지 경로 |
| `CONNECT_BY_ROOT` | 루트 노드의 컬럼 값 |
| `CONNECT_BY_ISLEAF` | 리프 노드 여부 (0 또는 1) |
| `ORDER SIBLINGS BY` | 같은 레벨 내 정렬 |

```sql
-- 경로 표시
SELECT 
    LEVEL,
    SYS_CONNECT_BY_PATH(name, ' > ') AS 경로,
    CONNECT_BY_ROOT name AS 최상위,
    CONNECT_BY_ISLEAF AS 리프여부
FROM staff
START WITH manager_id IS NULL
CONNECT BY PRIOR id = manager_id;
```

```text
+-------+---------------------------+--------+----------+
| LEVEL | 경로                       | 최상위  | 리프여부  |
+-------+---------------------------+--------+----------+
|     1 |  > 김대표                  | 김대표  |        0 |
|     2 |  > 김대표 > 이부장          | 김대표  |        0 |
|     3 |  > 김대표 > 이부장 > 박과장  | 김대표  |        0 |
|     4 |  > 김대표 > 이부장 > 박과장 > 최사원 | 김대표 |  1 |
+-------+---------------------------+--------+----------+
```

{% assign c-category = 'oracle' %}
{% assign c-tag = 'lecture-oracle' %}
{% include /custom-ref.html %}

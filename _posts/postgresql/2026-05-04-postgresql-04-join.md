---
title: "[PostgreSQL] 04. JOIN (테이블 결합)"
categories: 
    - postgresql
tags: 
    [postgresql, postgres, postgresql강좌, 중급, 'lecture-postgresql']
toc : true
toc_sticky  : true    
---

PostgreSQL에서 여러 테이블을 결합하여 데이터를 조회하는 JOIN을 정리합니다.

# 샘플 데이터 준비

```sql
CREATE TABLE departments (
    id    SERIAL PRIMARY KEY,
    name  VARCHAR(30) NOT NULL
);

CREATE TABLE employees (
    id       SERIAL PRIMARY KEY,
    name     VARCHAR(50) NOT NULL,
    dept_id  INTEGER REFERENCES departments(id),
    salary   NUMERIC(12,2)
);

INSERT INTO departments (name) VALUES ('개발팀'), ('기획팀'), ('디자인팀'), ('인사팀');

INSERT INTO employees (name, dept_id, salary) VALUES
('홍길동', 1, 5000000),
('김철수', 2, 4500000),
('이영희', 1, 5500000),
('박민수', 3, 4800000),
('최지은', NULL, 4000000);
```

---

## JOIN 종류

| JOIN 종류 | 설명 |
|----------|------|
| INNER JOIN | 양쪽 매칭되는 행만 |
| LEFT JOIN | 왼쪽 전체 + 오른쪽 매칭 |
| RIGHT JOIN | 오른쪽 전체 + 왼쪽 매칭 |
| FULL OUTER JOIN | 양쪽 전체 (매칭 안 되면 NULL) |
| CROSS JOIN | 모든 조합 (카테시안 곱) |
| SELF JOIN | 자기 자신과 결합 |
| LATERAL JOIN | 서브쿼리에서 외부 테이블 참조 (PostgreSQL 전용) |

---

## INNER JOIN
```sql
SELECT e.name AS 직원명, d.name AS 부서명, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.id;
```

## LEFT JOIN
```sql
SELECT e.name AS 직원명, d.name AS 부서명, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.id;

-- 매칭 안 되는 행만
SELECT e.name FROM employees e
LEFT JOIN departments d ON e.dept_id = d.id
WHERE d.id IS NULL;
```

## RIGHT JOIN
```sql
SELECT e.name AS 직원명, d.name AS 부서명
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.id;
```

## FULL OUTER JOIN
```sql
SELECT e.name AS 직원명, d.name AS 부서명
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.id;
```

## CROSS JOIN
```sql
SELECT e.name, d.name
FROM employees e
CROSS JOIN departments d;
```

## SELF JOIN
```sql
CREATE TABLE staff (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(50) NOT NULL,
    manager_id  INTEGER REFERENCES staff(id)
);

INSERT INTO staff (name, manager_id) VALUES
('김대표', NULL), ('이부장', 1), ('박과장', 2), ('최사원', 3);

SELECT s.name AS 직원, m.name AS 상사
FROM staff s
LEFT JOIN staff m ON s.manager_id = m.id;
```

---

## LATERAL JOIN (PostgreSQL 전용)

LATERAL을 사용하면 서브쿼리에서 외부 테이블의 컬럼을 참조할 수 있습니다.    
MySQL의 상관 서브쿼리를 JOIN 형태로 작성할 수 있어 성능과 가독성이 좋습니다.

```sql
-- 부서별 급여 상위 2명 조회
SELECT d.name AS 부서명, top_emp.name AS 직원명, top_emp.salary
FROM departments d
CROSS JOIN LATERAL (
    SELECT e.name, e.salary
    FROM employees e
    WHERE e.dept_id = d.id
    ORDER BY e.salary DESC
    LIMIT 2
) AS top_emp;
```

---

## NATURAL JOIN / USING

```sql
-- USING: 동일한 컬럼명으로 매칭
SELECT e.name, d.name AS dept_name
FROM employees e
JOIN departments d USING (id);  -- 양쪽에 id가 있을 때

-- NATURAL JOIN: 동일 컬럼명 자동 매칭 (비권장)
SELECT * FROM employees NATURAL JOIN departments;
```

---

## JOIN 사용 시 주의사항

| 주의사항 | 설명 |
|---------|------|
| ON 조건 필수 | 빠뜨리면 CROSS JOIN이 됨 |
| 별칭 사용 | 컬럼명 중복 시 반드시 테이블 별칭 |
| 인덱스 확인 | JOIN 컬럼에 인덱스가 없으면 성능 저하 |
| LEFT JOIN + WHERE | 오른쪽 테이블 조건을 WHERE에 넣으면 INNER JOIN과 동일해짐 |

{% assign c-category = 'postgresql' %}
{% assign c-tag = 'lecture-postgresql' %}
{% include /custom-ref.html %}

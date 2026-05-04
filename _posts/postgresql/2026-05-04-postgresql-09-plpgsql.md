---
title: "[PostgreSQL] 09. PL/pgSQL, 뷰, 함수, 트리거"
categories: 
    - postgresql
tags: 
    [postgresql, postgres, postgresql강좌, 중급, 'lecture-postgresql']
toc : true
toc_sticky  : true    
---

PostgreSQL의 PL/pgSQL, 뷰, 함수, 프로시저, 트리거를 정리합니다.

# 뷰 (View)

## 일반 뷰
```sql
CREATE OR REPLACE VIEW v_emp_dept AS
SELECT e.id, e.name, d.name AS dept_name, e.salary
FROM employees e
JOIN departments d ON e.dept_id = d.id;

SELECT * FROM v_emp_dept WHERE dept_name = '개발팀';

-- 뷰 삭제
DROP VIEW v_emp_dept;
DROP VIEW IF EXISTS v_emp_dept CASCADE;

-- 뷰 목록
\dv
SELECT viewname FROM pg_views WHERE schemaname = 'public';
```

## 머티리얼라이즈드 뷰 (Materialized View, PostgreSQL 전용)

일반 뷰와 달리 결과를 물리적으로 저장하여 빠르게 조회할 수 있습니다.

```sql
-- 생성
CREATE MATERIALIZED VIEW mv_dept_stats AS
SELECT d.name AS dept_name, COUNT(*) AS emp_count, AVG(e.salary) AS avg_salary
FROM employees e
JOIN departments d ON e.dept_id = d.id
GROUP BY d.name;

-- 조회 (일반 테이블처럼)
SELECT * FROM mv_dept_stats;

-- 데이터 갱신 (수동)
REFRESH MATERIALIZED VIEW mv_dept_stats;

-- 동시 갱신 (조회 차단 없이, UNIQUE INDEX 필요)
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_dept_stats;

-- 삭제
DROP MATERIALIZED VIEW mv_dept_stats;
```

---

## PL/pgSQL 기초

PL/pgSQL은 PostgreSQL의 절차적 확장 언어입니다. Oracle의 PL/SQL과 유사합니다.

### 익명 블록 (DO)
```sql
DO $$
DECLARE
    v_name TEXT;
    v_salary NUMERIC;
BEGIN
    SELECT name, salary INTO v_name, v_salary
    FROM employees WHERE id = 1;

    RAISE NOTICE '이름: %, 급여: %', v_name, v_salary;
END;
$$;
```

### 변수와 타입
```sql
DO $$
DECLARE
    v_id       INTEGER;
    v_name     TEXT := '홍길동';
    v_salary   NUMERIC(12,2) DEFAULT 0;
    v_active   BOOLEAN := TRUE;
    v_now      TIMESTAMPTZ := NOW();

    -- %TYPE: 테이블 컬럼과 동일한 타입
    v_emp_name employees.name%TYPE;

    -- %ROWTYPE: 테이블 행 전체 타입
    v_emp_row  employees%ROWTYPE;

    -- 상수
    c_tax_rate CONSTANT NUMERIC := 0.033;
BEGIN
    SELECT * INTO v_emp_row FROM employees WHERE id = 1;
    RAISE NOTICE '%: %', v_emp_row.name, v_emp_row.salary;
END;
$$;
```

### 조건문
```sql
DO $$
DECLARE
    v_salary NUMERIC := 5500000;
    v_grade  TEXT;
BEGIN
    IF v_salary >= 7000000 THEN
        v_grade := 'S';
    ELSIF v_salary >= 5000000 THEN
        v_grade := 'A';
    ELSIF v_salary >= 3000000 THEN
        v_grade := 'B';
    ELSE
        v_grade := 'C';
    END IF;

    RAISE NOTICE '등급: %', v_grade;
END;
$$;
```

### 반복문
```sql
DO $$
DECLARE
    v_sum INTEGER := 0;
    rec RECORD;
BEGIN
    -- FOR LOOP
    FOR i IN 1..10 LOOP
        v_sum := v_sum + i;
    END LOOP;
    RAISE NOTICE '합계: %', v_sum;  -- 55

    -- WHILE LOOP
    v_sum := 0;
    WHILE v_sum < 100 LOOP
        v_sum := v_sum + 10;
    END LOOP;

    -- 쿼리 결과 순회
    FOR rec IN SELECT name, salary FROM employees WHERE dept_id = 1 LOOP
        RAISE NOTICE '%: %', rec.name, rec.salary;
    END LOOP;
END;
$$;
```

### 예외 처리
```sql
DO $$
BEGIN
    INSERT INTO employees (id, name) VALUES (1, '중복');
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE '중복 키 오류 발생';
    WHEN OTHERS THEN
        RAISE NOTICE '오류: %', SQLERRM;
END;
$$;
```

---

## 함수 (Function)

```sql
-- 기본 함수
CREATE OR REPLACE FUNCTION fn_salary_grade(p_salary NUMERIC)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN CASE
        WHEN p_salary >= 7000000 THEN 'S'
        WHEN p_salary >= 5000000 THEN 'A'
        WHEN p_salary >= 3000000 THEN 'B'
        ELSE 'C'
    END;
END;
$$;

-- SQL에서 사용
SELECT name, salary, fn_salary_grade(salary) AS 등급 FROM employees;
```

### 테이블 반환 함수
```sql
CREATE OR REPLACE FUNCTION fn_get_dept_employees(p_dept_id INTEGER)
RETURNS TABLE(emp_name TEXT, emp_salary NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT name, salary FROM employees WHERE dept_id = p_dept_id;
END;
$$;

-- 사용
SELECT * FROM fn_get_dept_employees(1);
```

### SQL 함수 (간단한 경우)
```sql
CREATE OR REPLACE FUNCTION fn_add(a INTEGER, b INTEGER)
RETURNS INTEGER
LANGUAGE sql
AS $$
    SELECT a + b;
$$;
```

---

## 프로시저 (Procedure, PostgreSQL 11+)

함수와 달리 값을 반환하지 않으며, 트랜잭션 제어(COMMIT/ROLLBACK)가 가능합니다.

```sql
CREATE OR REPLACE PROCEDURE sp_update_salary(
    p_emp_id INTEGER,
    p_raise_pct NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current NUMERIC;
BEGIN
    SELECT salary INTO v_current FROM employees WHERE id = p_emp_id;

    IF v_current IS NULL THEN
        RAISE EXCEPTION '직원을 찾을 수 없습니다. ID: %', p_emp_id;
    END IF;

    UPDATE employees SET salary = v_current * (1 + p_raise_pct / 100)
    WHERE id = p_emp_id;

    COMMIT;
END;
$$;

-- 프로시저 호출
CALL sp_update_salary(1, 10);
```

### 함수 vs 프로시저

| 항목 | 함수 (FUNCTION) | 프로시저 (PROCEDURE) |
|------|----------------|---------------------|
| 반환값 | 필수 (RETURNS) | 없음 |
| 호출 | `SELECT fn()` | `CALL sp()` |
| SQL 내 사용 | SELECT, WHERE 등에서 가능 | 불가 |
| 트랜잭션 제어 | 불가 | COMMIT/ROLLBACK 가능 |
| 도입 버전 | 초기부터 | PostgreSQL 11+ |

---

## 트리거 (Trigger)

```sql
-- 급여 변경 이력 테이블
CREATE TABLE salary_log (
    id          SERIAL PRIMARY KEY,
    emp_id      INTEGER NOT NULL,
    old_salary  NUMERIC(12,2),
    new_salary  NUMERIC(12,2),
    changed_by  TEXT DEFAULT CURRENT_USER,
    changed_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 트리거 함수 (PostgreSQL은 트리거 함수를 먼저 생성)
CREATE OR REPLACE FUNCTION trg_fn_salary_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.salary IS DISTINCT FROM NEW.salary THEN
        INSERT INTO salary_log (emp_id, old_salary, new_salary)
        VALUES (OLD.id, OLD.salary, NEW.salary);
    END IF;
    RETURN NEW;
END;
$$;

-- 트리거 생성
CREATE TRIGGER trg_salary_change
AFTER UPDATE OF salary ON employees
FOR EACH ROW
EXECUTE FUNCTION trg_fn_salary_change();
```

### 트리거 관리
```sql
-- 트리거 목록
SELECT trigger_name, event_manipulation, action_timing
FROM information_schema.triggers
WHERE trigger_schema = 'public';

-- 트리거 비활성화 / 활성화
ALTER TABLE employees DISABLE TRIGGER trg_salary_change;
ALTER TABLE employees ENABLE TRIGGER trg_salary_change;
ALTER TABLE employees DISABLE TRIGGER ALL;

-- 트리거 삭제
DROP TRIGGER trg_salary_change ON employees;
```

{% assign c-category = 'postgresql' %}
{% assign c-tag = 'lecture-postgresql' %}
{% include /custom-ref.html %}

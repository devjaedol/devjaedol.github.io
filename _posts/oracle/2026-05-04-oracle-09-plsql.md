---
title: "[Oracle] 09. PL/SQL, 뷰, 프로시저, 트리거"
categories: 
    - oracle
tags: 
    [oracle, oracle강좌, 중급, 'lecture-oracle']
toc : true
toc_sticky  : true    
---

Oracle의 PL/SQL 기초, 뷰, 스토어드 프로시저, 함수, 패키지, 트리거를 정리합니다.

# PL/SQL 기초

PL/SQL(Procedural Language/SQL)은 Oracle의 절차적 확장 언어입니다.    
SQL에 변수, 조건문, 반복문, 예외 처리 등 프로그래밍 기능을 추가합니다.

## 기본 구조
```sql
DECLARE
    -- 변수 선언부
    v_name VARCHAR2(50);
    v_salary NUMBER(12,2);
BEGIN
    -- 실행부
    SELECT name, salary INTO v_name, v_salary
    FROM employees WHERE id = 1;
    
    DBMS_OUTPUT.PUT_LINE('이름: ' || v_name || ', 급여: ' || v_salary);
EXCEPTION
    -- 예외 처리부
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('데이터가 없습니다.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류: ' || SQLERRM);
END;
/
```

> `DBMS_OUTPUT.PUT_LINE` 출력을 보려면 `SET SERVEROUTPUT ON`을 먼저 실행하세요.

### 변수와 타입
```sql
DECLARE
    v_id        NUMBER(10);
    v_name      VARCHAR2(50) := '홍길동';       -- 초기값 설정
    v_salary    NUMBER(12,2) DEFAULT 0;         -- DEFAULT 사용
    v_hire_date DATE := SYSDATE;
    v_is_active BOOLEAN := TRUE;                -- PL/SQL에서만 사용 가능
    
    -- %TYPE: 테이블 컬럼과 동일한 타입
    v_emp_name  employees.name%TYPE;
    
    -- %ROWTYPE: 테이블 행 전체 타입
    v_emp_row   employees%ROWTYPE;
    
    -- 상수
    c_tax_rate  CONSTANT NUMBER := 0.033;
BEGIN
    SELECT * INTO v_emp_row FROM employees WHERE id = 1;
    DBMS_OUTPUT.PUT_LINE(v_emp_row.name || ': ' || v_emp_row.salary);
END;
/
```

### 조건문
```sql
DECLARE
    v_salary NUMBER := 5500000;
    v_grade  VARCHAR2(10);
BEGIN
    -- IF-ELSIF-ELSE
    IF v_salary >= 7000000 THEN
        v_grade := 'S';
    ELSIF v_salary >= 5000000 THEN
        v_grade := 'A';
    ELSIF v_salary >= 3000000 THEN
        v_grade := 'B';
    ELSE
        v_grade := 'C';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('등급: ' || v_grade);
    
    -- CASE
    v_grade := CASE
        WHEN v_salary >= 7000000 THEN 'S'
        WHEN v_salary >= 5000000 THEN 'A'
        ELSE 'B'
    END;
END;
/
```

### 반복문
```sql
DECLARE
    v_sum NUMBER := 0;
BEGIN
    -- 기본 LOOP
    LOOP
        v_sum := v_sum + 1;
        EXIT WHEN v_sum >= 10;
    END LOOP;
    
    -- WHILE LOOP
    v_sum := 0;
    WHILE v_sum < 10 LOOP
        v_sum := v_sum + 1;
    END LOOP;
    
    -- FOR LOOP
    v_sum := 0;
    FOR i IN 1..10 LOOP
        v_sum := v_sum + i;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('합계: ' || v_sum);  -- 55
    
    -- 역순 FOR LOOP
    FOR i IN REVERSE 1..10 LOOP
        DBMS_OUTPUT.PUT_LINE(i);
    END LOOP;
END;
/
```

### 커서 (Cursor)
```sql
DECLARE
    -- 명시적 커서
    CURSOR c_emp IS
        SELECT id, name, salary FROM employees WHERE dept_id = 1;
    v_emp c_emp%ROWTYPE;
BEGIN
    OPEN c_emp;
    LOOP
        FETCH c_emp INTO v_emp;
        EXIT WHEN c_emp%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_emp.name || ': ' || v_emp.salary);
    END LOOP;
    CLOSE c_emp;
END;
/

-- FOR LOOP 커서 (더 간결)
BEGIN
    FOR rec IN (SELECT name, salary FROM employees WHERE dept_id = 1) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.name || ': ' || rec.salary);
    END LOOP;
END;
/
```

---

## 뷰 (View)

```sql
-- 뷰 생성
CREATE OR REPLACE VIEW v_emp_dept AS
SELECT e.id, e.name, d.name AS dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.id;

-- 뷰 사용
SELECT * FROM v_emp_dept WHERE dept_name = '개발팀';

-- 읽기 전용 뷰
CREATE OR REPLACE VIEW v_emp_public AS
SELECT id, name, dept_id, hire_date FROM employees
WITH READ ONLY;

-- 뷰 삭제
DROP VIEW v_emp_dept;

-- 뷰 목록
SELECT view_name FROM user_views;

-- 뷰 DDL 확인
SELECT text FROM user_views WHERE view_name = 'V_EMP_DEPT';
```

---

## 스토어드 프로시저 (Stored Procedure)

```sql
-- 기본 프로시저
CREATE OR REPLACE PROCEDURE sp_get_emp_by_dept (
    p_dept_id IN NUMBER
)
IS
    CURSOR c_emp IS
        SELECT name, salary FROM employees WHERE dept_id = p_dept_id;
BEGIN
    FOR rec IN c_emp LOOP
        DBMS_OUTPUT.PUT_LINE(rec.name || ': ' || rec.salary);
    END LOOP;
END;
/

-- 프로시저 호출
EXEC sp_get_emp_by_dept(1);
-- 또는
BEGIN
    sp_get_emp_by_dept(1);
END;
/
```

### OUT 파라미터
```sql
CREATE OR REPLACE PROCEDURE sp_get_dept_stats (
    p_dept_id    IN  NUMBER,
    p_count      OUT NUMBER,
    p_avg_salary OUT NUMBER
)
IS
BEGIN
    SELECT COUNT(*), AVG(salary)
    INTO p_count, p_avg_salary
    FROM employees
    WHERE dept_id = p_dept_id;
END;
/

-- 호출
DECLARE
    v_count NUMBER;
    v_avg   NUMBER;
BEGIN
    sp_get_dept_stats(1, v_count, v_avg);
    DBMS_OUTPUT.PUT_LINE('인원: ' || v_count || ', 평균급여: ' || v_avg);
END;
/
```

### 예외 처리가 포함된 프로시저
```sql
CREATE OR REPLACE PROCEDURE sp_update_salary (
    p_emp_id    IN NUMBER,
    p_raise_pct IN NUMBER
)
IS
    v_current_salary NUMBER;
    e_invalid_raise EXCEPTION;
BEGIN
    SELECT salary INTO v_current_salary
    FROM employees WHERE id = p_emp_id;
    
    IF p_raise_pct > 50 THEN
        RAISE e_invalid_raise;
    END IF;
    
    UPDATE employees
    SET salary = v_current_salary * (1 + p_raise_pct / 100)
    WHERE id = p_emp_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('급여 변경 완료');
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('직원을 찾을 수 없습니다. ID: ' || p_emp_id);
    WHEN e_invalid_raise THEN
        DBMS_OUTPUT.PUT_LINE('인상률은 50%를 초과할 수 없습니다.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('오류 발생: ' || SQLERRM);
END;
/
```

---

## 사용자 정의 함수 (Function)

```sql
CREATE OR REPLACE FUNCTION fn_salary_grade (
    p_salary NUMBER
) RETURN VARCHAR2
IS
    v_grade VARCHAR2(10);
BEGIN
    v_grade := CASE
        WHEN p_salary >= 7000000 THEN 'S'
        WHEN p_salary >= 5000000 THEN 'A'
        WHEN p_salary >= 3000000 THEN 'B'
        ELSE 'C'
    END;
    RETURN v_grade;
END;
/

-- SQL에서 사용
SELECT name, salary, fn_salary_grade(salary) AS 등급 FROM employees;
```

---

## 패키지 (Package) - Oracle 전용

패키지는 관련된 프로시저, 함수, 변수, 커서 등을 하나로 묶는 Oracle 고유 기능입니다.

```sql
-- 패키지 명세 (인터페이스)
CREATE OR REPLACE PACKAGE pkg_employee
IS
    PROCEDURE get_by_dept(p_dept_id NUMBER);
    FUNCTION get_grade(p_salary NUMBER) RETURN VARCHAR2;
    PROCEDURE update_salary(p_emp_id NUMBER, p_raise_pct NUMBER);
END pkg_employee;
/

-- 패키지 본문 (구현)
CREATE OR REPLACE PACKAGE BODY pkg_employee
IS
    PROCEDURE get_by_dept(p_dept_id NUMBER)
    IS
    BEGIN
        FOR rec IN (SELECT name, salary FROM employees WHERE dept_id = p_dept_id) LOOP
            DBMS_OUTPUT.PUT_LINE(rec.name || ': ' || rec.salary);
        END LOOP;
    END;
    
    FUNCTION get_grade(p_salary NUMBER) RETURN VARCHAR2
    IS
    BEGIN
        RETURN CASE
            WHEN p_salary >= 7000000 THEN 'S'
            WHEN p_salary >= 5000000 THEN 'A'
            ELSE 'B'
        END;
    END;
    
    PROCEDURE update_salary(p_emp_id NUMBER, p_raise_pct NUMBER)
    IS
    BEGIN
        UPDATE employees SET salary = salary * (1 + p_raise_pct / 100)
        WHERE id = p_emp_id;
        COMMIT;
    END;
END pkg_employee;
/

-- 패키지 사용
EXEC pkg_employee.get_by_dept(1);
SELECT pkg_employee.get_grade(salary) FROM employees;
```

---

## 트리거 (Trigger)

```sql
-- 급여 변경 이력 테이블
CREATE TABLE salary_log (
    id          NUMBER GENERATED ALWAYS AS IDENTITY,
    emp_id      NUMBER NOT NULL,
    old_salary  NUMBER(12,2),
    new_salary  NUMBER(12,2),
    changed_by  VARCHAR2(50),
    changed_at  TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- 트리거 생성
CREATE OR REPLACE TRIGGER trg_salary_change
AFTER UPDATE OF salary ON employees
FOR EACH ROW
BEGIN
    INSERT INTO salary_log (emp_id, old_salary, new_salary, changed_by)
    VALUES (:OLD.id, :OLD.salary, :NEW.salary, USER);
END;
/
```

### 트리거 타이밍

| 타이밍 | 설명 |
|--------|------|
| BEFORE INSERT | INSERT 전 (데이터 검증, 기본값 설정) |
| AFTER INSERT | INSERT 후 (로그 기록) |
| BEFORE UPDATE | UPDATE 전 (변경 전 검증) |
| AFTER UPDATE | UPDATE 후 (변경 이력 기록) |
| BEFORE DELETE | DELETE 전 (삭제 전 검증) |
| AFTER DELETE | DELETE 후 (삭제 이력 기록) |
| INSTEAD OF | 뷰에 대한 DML을 대체 실행 |

### 트리거 관리
```sql
-- 트리거 목록
SELECT trigger_name, trigger_type, triggering_event, status
FROM user_triggers;

-- 트리거 비활성화 / 활성화
ALTER TRIGGER trg_salary_change DISABLE;
ALTER TRIGGER trg_salary_change ENABLE;

-- 테이블의 모든 트리거 비활성화
ALTER TABLE employees DISABLE ALL TRIGGERS;

-- 트리거 삭제
DROP TRIGGER trg_salary_change;
```

{% assign c-category = 'oracle' %}
{% assign c-tag = 'lecture-oracle' %}
{% include /custom-ref.html %}

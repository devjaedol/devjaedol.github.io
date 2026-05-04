---
title: "[MySQL] 09. 뷰, 스토어드 프로시저, 함수, 트리거"
categories: 
    - mysql
tags: 
    [mysql, mariadb, mysql강좌, 중급, 'lecture-mysql']
toc : true
toc_sticky  : true    
---

뷰(View), 스토어드 프로시저(Stored Procedure), 사용자 정의 함수(Function), 트리거(Trigger)를 정리합니다.

# 뷰 (View)

뷰는 하나 이상의 테이블에서 데이터를 조회하는 가상 테이블입니다.    
실제 데이터를 저장하지 않고, 쿼리 결과를 테이블처럼 사용할 수 있습니다.

## 뷰 생성
```sql
-- 기본 뷰 생성
CREATE VIEW v_employee_dept AS
SELECT e.id, e.name, d.name AS dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.id;

-- 뷰 사용 (테이블처럼 조회)
SELECT * FROM v_employee_dept WHERE dept_name = '개발팀';
```

### 뷰 수정 및 삭제
```sql
-- 뷰 수정 (없으면 생성)
CREATE OR REPLACE VIEW v_employee_dept AS
SELECT e.id, e.name, d.name AS dept_name, e.salary, e.hire_date
FROM employees e
INNER JOIN departments d ON e.dept_id = d.id;

-- 뷰 삭제
DROP VIEW v_employee_dept;
DROP VIEW IF EXISTS v_employee_dept;

-- 뷰 목록 확인
SHOW FULL TABLES WHERE Table_type = 'VIEW';
```

### 뷰 활용 사례

| 용도 | 설명 |
|------|------|
| 보안 | 민감한 컬럼(급여, 비밀번호)을 제외한 뷰 제공 |
| 편의성 | 복잡한 JOIN 쿼리를 뷰로 단순화 |
| 일관성 | 자주 사용하는 쿼리를 뷰로 통일 |

```sql
-- 보안 뷰: 급여 정보 제외
CREATE VIEW v_employee_public AS
SELECT id, name, dept_id, hire_date FROM employees;
```

---

## 스토어드 프로시저 (Stored Procedure)

미리 컴파일된 SQL 문의 집합으로, 서버에 저장되어 호출하여 실행합니다.

### 기본 프로시저
```sql
-- 구분자 변경 (프로시저 내부에서 ; 사용을 위해)
DELIMITER //

CREATE PROCEDURE sp_get_employees_by_dept(IN p_dept_id INT)
BEGIN
    SELECT id, name, salary
    FROM employees
    WHERE dept_id = p_dept_id
    ORDER BY salary DESC;
END //

DELIMITER ;

-- 프로시저 호출
CALL sp_get_employees_by_dept(1);
```

### 파라미터 종류

| 종류 | 설명 | 예시 |
|------|------|------|
| IN | 입력 파라미터 (기본값) | `IN p_id INT` |
| OUT | 출력 파라미터 | `OUT p_count INT` |
| INOUT | 입출력 파라미터 | `INOUT p_value INT` |

### OUT 파라미터 예시
```sql
DELIMITER //

CREATE PROCEDURE sp_get_dept_stats(
    IN p_dept_id INT,
    OUT p_count INT,
    OUT p_avg_salary DECIMAL(10,2)
)
BEGIN
    SELECT COUNT(*), AVG(salary)
    INTO p_count, p_avg_salary
    FROM employees
    WHERE dept_id = p_dept_id;
END //

DELIMITER ;

-- 호출 및 결과 확인
CALL sp_get_dept_stats(1, @cnt, @avg);
SELECT @cnt AS 인원수, @avg AS 평균급여;
```

### 제어문 사용
```sql
DELIMITER //

CREATE PROCEDURE sp_update_salary(
    IN p_emp_id INT,
    IN p_raise_pct DECIMAL(5,2)
)
BEGIN
    DECLARE v_current_salary DECIMAL(10,2);
    DECLARE v_new_salary DECIMAL(10,2);
    
    -- 현재 급여 조회
    SELECT salary INTO v_current_salary
    FROM employees WHERE id = p_emp_id;
    
    -- 조건 분기
    IF v_current_salary IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '직원을 찾을 수 없습니다';
    ELSEIF p_raise_pct > 50 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '인상률은 50%를 초과할 수 없습니다';
    ELSE
        SET v_new_salary = v_current_salary * (1 + p_raise_pct / 100);
        UPDATE employees SET salary = v_new_salary WHERE id = p_emp_id;
        SELECT CONCAT(p_emp_id, '번 직원 급여 변경: ', v_current_salary, ' → ', v_new_salary) AS 결과;
    END IF;
END //

DELIMITER ;
```

### 반복문
```sql
DELIMITER //

CREATE PROCEDURE sp_insert_test_data(IN p_count INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    
    WHILE i <= p_count DO
        INSERT INTO test_table (name, value)
        VALUES (CONCAT('item_', i), FLOOR(RAND() * 1000));
        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

CALL sp_insert_test_data(100);
```

### 프로시저 관리
```sql
-- 프로시저 목록
SHOW PROCEDURE STATUS WHERE Db = 'mydb';

-- 프로시저 내용 확인
SHOW CREATE PROCEDURE sp_get_employees_by_dept;

-- 프로시저 삭제
DROP PROCEDURE IF EXISTS sp_get_employees_by_dept;
```

---

## 사용자 정의 함수 (Function)

프로시저와 유사하지만, 반드시 값을 반환하며 SELECT 문 안에서 사용할 수 있습니다.

```sql
DELIMITER //

CREATE FUNCTION fn_salary_grade(p_salary DECIMAL(10,2))
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE v_grade VARCHAR(10);
    
    IF p_salary >= 7000000 THEN SET v_grade = 'S';
    ELSEIF p_salary >= 5000000 THEN SET v_grade = 'A';
    ELSEIF p_salary >= 3000000 THEN SET v_grade = 'B';
    ELSE SET v_grade = 'C';
    END IF;
    
    RETURN v_grade;
END //

DELIMITER ;

-- 함수 사용
SELECT name, salary, fn_salary_grade(salary) AS 등급 FROM employees;
```

### 프로시저 vs 함수

| 항목 | 프로시저 | 함수 |
|------|---------|------|
| 반환값 | 없거나 OUT 파라미터 | 반드시 RETURN |
| 호출 방법 | `CALL 프로시저명()` | `SELECT 함수명()` |
| SQL 내 사용 | 불가 | SELECT, WHERE 등에서 사용 가능 |
| 트랜잭션 | 사용 가능 | 제한적 |

---

## 트리거 (Trigger)

특정 테이블에 INSERT, UPDATE, DELETE가 발생할 때 자동으로 실행되는 프로시저입니다.

### 트리거 생성
```sql
-- 급여 변경 이력 테이블
CREATE TABLE salary_log (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    emp_id      INT NOT NULL,
    old_salary  DECIMAL(10,2),
    new_salary  DECIMAL(10,2),
    changed_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 급여 변경 시 자동 로그 기록
DELIMITER //

CREATE TRIGGER trg_salary_change
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF OLD.salary != NEW.salary THEN
        INSERT INTO salary_log (emp_id, old_salary, new_salary)
        VALUES (OLD.id, OLD.salary, NEW.salary);
    END IF;
END //

DELIMITER ;
```

### 트리거 타이밍

| 타이밍 | 이벤트 | 설명 |
|--------|--------|------|
| BEFORE INSERT | INSERT 전 | 데이터 검증, 기본값 설정 |
| AFTER INSERT | INSERT 후 | 로그 기록, 연관 테이블 업데이트 |
| BEFORE UPDATE | UPDATE 전 | 변경 전 검증 |
| AFTER UPDATE | UPDATE 후 | 변경 이력 기록 |
| BEFORE DELETE | DELETE 전 | 삭제 전 검증 |
| AFTER DELETE | DELETE 후 | 삭제 이력 기록 |

### OLD / NEW 키워드

| 이벤트 | OLD | NEW |
|--------|-----|-----|
| INSERT | 사용 불가 | 새로 삽입되는 값 |
| UPDATE | 변경 전 값 | 변경 후 값 |
| DELETE | 삭제되는 값 | 사용 불가 |

### 트리거 관리
```sql
-- 트리거 목록
SHOW TRIGGERS;

-- 트리거 삭제
DROP TRIGGER IF EXISTS trg_salary_change;
```

{% assign c-category = 'mysql' %}
{% assign c-tag = 'lecture-mysql' %}
{% include /custom-ref.html %}

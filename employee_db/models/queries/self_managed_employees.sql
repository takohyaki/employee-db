{{ config(materialized='table') }}

-- Question 5

WITH employee_managers AS (
    SELECT
        e.emp_no,
        e.first_name,
        e.last_name,
        e.birth_date,
        e.gender,
        e.hire_date,
        dm.dept_no,
        dm.from_date,
        dm.to_date
    FROM {{ ref('stg_employees') }} e
    JOIN {{ ref('stg_dept_manager') }} dm ON e.emp_no = dm.emp_no
)

-- Select employees who are their own managers
SELECT
    emp_no,
    first_name,
    last_name,
    birth_date,
    gender,
    hire_date,
    dept_no,
    from_date,
    to_date
FROM employee_managers
WHERE emp_no IN (SELECT emp_no FROM {{ ref('stg_dept_manager') }} WHERE emp_no = emp_no)


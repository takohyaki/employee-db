{{ config(materialized='table') }}

WITH employees AS (
    SELECT
        emp_no,
        birth_date,
        first_name,
        last_name,
        gender,
        hire_date -- This is actually the from_date from the stg_dept_manager
    FROM {{ ref('raw_employees') }}
),
dept_manager AS (
    SELECT
        emp_no,
        from_date AS hire_date -- We'll use this as the hire_date
    FROM {{ ref('stg_dept_manager') }}
)

-- Union the data from both CTEs and insert into stg_employees table
SELECT
    emp_no,
    birth_date,
    first_name,
    last_name,
    gender,
    hire_date
FROM employees

UNION ALL

SELECT
    emp_no,
    NULL AS birth_date,  -- birth_date is not available in stg_dept_manager
    NULL AS first_name,  -- first_name is not available in stg_dept_manager
    NULL AS last_name,   -- last_name is not available in stg_dept_manager
    NULL AS gender,      -- gender is not available in stg_dept_manager
    hire_date
FROM dept_manager

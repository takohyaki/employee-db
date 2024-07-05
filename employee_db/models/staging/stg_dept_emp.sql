{{ config(materialized='table') }}

WITH dept_emp AS (
    SELECT
        emp_no,
        dept_no,
        from_date,
        to_date
    FROM {{ ref('raw_dept_emp') }}
),
dept_manager AS (
    SELECT
        emp_no,
        dept_no,
        from_date, 
        to_date
    FROM {{ ref('stg_dept_manager') }}
)

-- Union the data from both CTEs and insert into stg_dept_emp table
SELECT
    emp_no,
    dept_no,
    from_date,
    to_date
FROM dept_emp

UNION ALL

SELECT
    emp_no,
    dept_no,
    from_date,
    to_date
FROM dept_manager
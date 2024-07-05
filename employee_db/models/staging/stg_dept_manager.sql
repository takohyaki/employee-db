{{ config(materialized='table') }}

SELECT
    emp_no,
    dept_no,
    from_date,
    to_date
FROM {{ ref('raw_dept_manager') }}

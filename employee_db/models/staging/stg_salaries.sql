{{ config(materialized='table') }}

SELECT
    emp_no,
    salary,
    from_date,
    to_date
FROM {{ ref('raw_salaries') }}

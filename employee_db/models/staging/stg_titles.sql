{{ config(materialized='table') }}

SELECT
    emp_no,
    title,
    from_date,
    to_date
FROM {{ ref('raw_titles') }}

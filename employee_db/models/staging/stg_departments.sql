{{ config(materialized='table') }}

SELECT
    dept_no,
    dept_name
FROM {{ ref('raw_departments') }}

{{ config(materialized='table') }}

-- Question 1

SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    d.dept_no,
    d.dept_name
FROM {{ ref('stg_employees') }} e
JOIN {{ ref('stg_dept_emp') }} de ON e.emp_no = de.emp_no
JOIN {{ ref('stg_departments') }} d ON de.dept_no = d.dept_no
ORDER BY d.dept_no, e.emp_no

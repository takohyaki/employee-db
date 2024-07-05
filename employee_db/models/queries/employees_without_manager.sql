{{ config(materialized='table') }}

-- Question 4

SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    e.hire_date
FROM {{ ref('stg_employees') }} e
LEFT JOIN {{ ref('stg_dept_emp') }} de ON e.emp_no = de.emp_no
LEFT JOIN {{ ref('stg_dept_manager') }} dm ON de.dept_no = dm.dept_no
WHERE dm.emp_no IS NULL
ORDER BY e.emp_no

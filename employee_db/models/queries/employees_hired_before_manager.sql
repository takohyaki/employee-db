{{ config(materialized='table') }}

-- Question 6

SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    e.hire_date,
    m.emp_no AS manager_emp_no,
    m.hire_date AS manager_hire_date
FROM {{ ref('stg_employees') }} e
JOIN {{ ref('stg_dept_emp') }} de ON e.emp_no = de.emp_no
JOIN {{ ref('stg_dept_manager') }} dm ON de.dept_no = dm.dept_no
JOIN {{ ref('stg_employees') }} m ON dm.emp_no = m.emp_no
WHERE e.hire_date < m.hire_date
  AND e.emp_no NOT IN (SELECT emp_no FROM {{ ref('stg_dept_manager') }}) -- Ensure that managers are not included
ORDER BY e.emp_no


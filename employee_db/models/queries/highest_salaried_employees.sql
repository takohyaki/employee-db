{{ config(materialized='table') }}

-- Question 3

WITH ranked_salaries AS (
    SELECT
        e.emp_no,
        e.first_name,
        e.last_name,
        s.salary,
        de.dept_no,
        d.dept_name,
        RANK() OVER (PARTITION BY de.dept_no ORDER BY s.salary DESC) AS salary_rank
    FROM {{ ref('stg_employees') }} e
    JOIN {{ ref('stg_salaries') }} s ON e.emp_no = s.emp_no
    JOIN {{ ref('stg_dept_emp') }} de ON e.emp_no = de.emp_no
    JOIN {{ ref('stg_departments') }} d ON de.dept_no = d.dept_no
    WHERE s.to_date = '9999-01-01'
)
SELECT
    emp_no,
    first_name,
    last_name,
    dept_no,
    dept_name,
    salary
FROM ranked_salaries
WHERE salary_rank = 1
ORDER BY dept_no


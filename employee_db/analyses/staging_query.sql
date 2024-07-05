-- BigQuery queries

-- Query 1: Find how many manager employee_ids are not in the employees table
SELECT dm.emp_no, e.emp_no AS employee_emp_no
FROM `workato-employee-db-425013.employee_db_public.stg_dept_manager` dm
LEFT JOIN `workato-employee-db-425013.employee_db_public.stg_employees` e
ON dm.emp_no = e.emp_no
WHERE e.emp_no IS NULL;

-- Query 2: Count the number of manager employee_ids that are not in the salaries table
SELECT COUNT(dm.emp_no)
FROM `workato-employee-db-425013.employee_db_public.stg_dept_manager` dm
LEFT JOIN `workato-employee-db-425013.employee_db_public.stg_employees` e
ON dm.emp_no = e.emp_no
WHERE e.emp_no IS NULL;

-- Query 3: Count the number of manager employee_ids there are in dept_manager table
SELECT COUNT(emp_no)
FROM `workato-employee-db-425013.employee_db_public.stg_dept_manager`;
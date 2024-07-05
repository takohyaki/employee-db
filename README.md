# Employee Data Pipeline

# Introduction

Utilized dbt modeling as the data schema of choice. Check the documentation [here](https://docs.getdbt.com/).

## dbt Setup

To set up dbt, follow these steps:

1. **Install dbt**:
   - Use pip to install dbt for your specific data warehouse. For example, for BigQuery:
     ```sh
     pip install dbt-bigquery
     ```

2. **Initialize a dbt Project**:
   - Create a new dbt project:
     ```sh
     dbt init employee_db
     ```
   - Navigate to the project directory:
     ```sh
     cd employee_db
     ```

3. **Configure dbt**:
   - Edit the `profiles.yml` file to include your database connection details. For BigQuery, it would look something like this:
     ```yaml
     employee_db:
       target: dev
       outputs:
         dev:
           type: bigquery
           method: service-account
           project: your-project-id
           dataset: your-dataset
           keyfile: path-to-your-service-account-key.json
           threads: 1
           timeout_seconds: 300
           location: US
     ```

4. **Run dbt Commands**:
   - To test the connection:
     ```sh
     dbt debug
     ```
   - To run models:
     ```sh
     dbt run
     ```
   - To test models:
     ```sh
     dbt test
     ```

## Package Structure

Here is the package structure for the `employee_db` project:

```
employee_db/
|-- analyses/             # Directory for analysis SQL files
|-- macros/               # Directory for custom macros
|   |-- tests/            # Directory for custom test macros
|-- models/               # Directory for dbt models
|   |-- dbt_packages/     # Directory for installed dbt packages
|   |-- queries/          # Directory for SQL query files
|   |-- staging/          # Directory for staging models
|-- seeds/                # Directory for seed CSV files
|-- snapshots/            # Directory for snapshot files
|-- .gitignore            # Git ignore file
|-- dbt_project.yml       # dbt project configuration file
```


### Comments on Key Directories

- **analyses/**: Contains analysis SQL files for ad-hoc queries or exploration.
- **macros/**: Contains custom macros that can be reused in models and tests.
  - **tests/**: Stores custom test macros for validating data models.
- **models/**: Contains dbt models, which are the core of dbt projects.
  - **dbt_packages/**: Stores installed dbt packages (like reusable models, macros, etc.).
  - **queries/**: Holds raw SQL query files used in the project.
  - **staging/**: Contains staging models used to prepare raw data for further transformations.
- **seeds/**: Contains seed CSV files that can be loaded into the database.
- **snapshots/**: Stores snapshot files for capturing data changes over time.
- **dbt_project.yml**: The configuration file for the dbt project, defining project settings, models, seeds, snapshots, etc.

# Process

## Raw Data

Imported CSVs from Dropbox with names prefixed with `raw_` for greater differentiation.

## Staging (Data Preparation)

### Initial Setup
Initially, I finished the queries, but there were 0 entries for `employees_salary_exceeds_manager`. Upon inspection, it was clear that the manager `emp_no` (employee ID) was absent from the `employees` table.

### Analysis
Found in `employee_db/analyses/staging_query.sql`
1. **Query 1**: This query revealed that many employee IDs for the managers were missing.
2. **Query 2**: Confirmed that 24 manager IDs were missing.
3. **Query 3**: Verified that the total number of IDs in `dept_manager` is 24.

### Solution
Overwrite `stg_employees` table with inserted IDs and hire dates found in `dept_manager`.

### Incremental Load (Hypothetical)
Without billing enabled, I cannot use DML queries, including incremental loads. If full access were available, `stg_employees` would be adapted as follows:

```sql
{{ config(
    materialized='incremental',
    unique_key='emp_no'
) }}

WITH employees AS (
    SELECT
        emp_no,
        birth_date,
        first_name,
        last_name,
        gender,
        hire_date
    FROM {{ ref('raw_employees') }}
    {% if is_incremental() %}
        WHERE hire_date > (SELECT MAX(hire_date) FROM {{ this }})
    {% endif %}
),
dept_manager AS (
    SELECT
        emp_no,
        from_date AS hire_date
    FROM {{ ref('stg_dept_manager') }}
    {% if is_incremental() %}
        WHERE from_date > (SELECT MAX(hire_date) FROM {{ this }})
    {% endif %}
)

SELECT
    emp_no,
    birth_date,
    first_name,
    last_name,
    gender,
    hire_date
FROM employees

UNION ALL

SELECT
    emp_no,
    NULL AS birth_date,
    NULL AS first_name,
    NULL AS last_name,
    NULL AS gender,
    hire_date
FROM dept_manager
```

### Explanation:
- Incremental Load: Filters data to only include records with `hire_date` greater than the maximum `hire_date` in the existing table (`{{ this }}`) for an incremental run. This prevents running a full load and processes only new changes.
- Importance: Especially important with BigQuery where costs are based on the amount of data processed. This also allows the pipeline to run more frequently, ensuring the warehouse is always up-to-date with the latest changes

# Testing
Added tests apart from built-in non_null and unique.

## Observations
- Not-null Failures: gender, first name, and last name for employees fail as I added the `dept_manager` info into the `employees` table.
- Strange `emp_no` Values: Found some unusual `emp_no` in the tables, e.g., `emp_no`: 1, `birth_date`: 1977-06-14, `first_name`: Geert, `last_name`: Vanderkelen, gender: M, hire_date: 2018-04-22.

## Custom Test
Added the test `min_length_5_digits.sql` found in `employee_db/macros/test/min_length_5_digits.sql`. This test checks if the `emp_no` is at least 5 digits.

# Future Work
There are many more comprehensive tests I could add, but for the sake of a simple DBT model, I have started with these basic validations.

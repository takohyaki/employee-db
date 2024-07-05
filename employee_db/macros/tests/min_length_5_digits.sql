{% test min_length_5_digits(model, column_name) %}
WITH validation AS (
    SELECT
        {{ column_name }} AS value,
        LENGTH(CAST({{ column_name }} AS STRING)) AS length
    FROM {{ model }}
)
SELECT *
FROM validation
WHERE length < 5
{% endtest %}

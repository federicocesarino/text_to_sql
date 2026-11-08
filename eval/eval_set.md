## Q1
Question: How many systolic blood pressure measurements are in the database?
Difficulty: easy
SQL:
SELECT COUNT(*)
FROM lab_results
WHERE DESCRIPTION = 'Systolic Blood Pressure';
Expected result: 14467

## Q2
Question: How many stress findings are there in the database?
Difficulty: easy
SQL:
SELECT
COUNT(*)
FROM conditions
WHERE DESCRIPTION = 'Stress (finding)';
Expected result: 5137

## Q3
Question: How many patients have been diagnosed with stress?
Difficulty: easy
SQL:
SELECT COUNT(DISTINCT PATIENT)
FROM conditions
WHERE DESCRIPTION = 'Stress (finding)';
Expected result: (il numero che ottieni)
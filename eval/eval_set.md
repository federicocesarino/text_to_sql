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
Expected result: 894

## Q4
Question: How many female patients have been diagnosed with hypertension?
Difficulty: medium
SQL:
SELECT
COUNT(DISTINCT(p.Id))
FROM patients AS p
INNER JOIN conditions AS c
ON p.id = c.PATIENT
WHERE p.GENDER = 'F'
AND c.DESCRIPTION = 'Hypertension'
Expected result: 146

## Q5
Question: How many systolic blood pressure measurements were taken in 2020?
Difficulty: medium
SQL:
SELECT 
COUNT(*)
FROM observations
WHERE DESCRIPTION = 'Systolic Blood Pressure'
AND cast(substr(DATE,1,4) AS REAL) = 2020
Expected result: 1390

## Q6
Question: What are the five most commonly prescribed medications?
Difficulty: medium
SQL:
WITH ranked AS (
  SELECT
    DESCRIPTION,
    COUNT(*) AS n,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS rk
  FROM medications
  GROUP BY DESCRIPTION
)
SELECT DESCRIPTION, n, rk
FROM ranked
WHERE rk <= 5
ORDER BY rk;
Expected result:
lisinopril 10 MG Oral Tablet	8166
Hydrochlorothiazide 25 MG Oral Tablet	7509
amLODIPine 2.5 MG Oral Tablet	5942
insulin human  isophane 70 UNT/ML / Regular Insulin  Human 30 UNT/ML Injectable Suspension [Humulin]	4068
24 HR Metformin hydrochloride 500 MG Extended Release Oral Tablet	2996

## Q7
Question: How many patients born before 1960 are still alive?
Difficulty: medium
SQL:
SELECT 
COUNT(*)
FROM patients
WHERE CAST(substr(BIRTHDATE,1,4) AS REAL) < 1960
AND DEATHDATE = ''
Expected result: 187

## Q8
Question: How many patients are hypertensive based on their most recent blood pressure reading?
Difficulty: hard
Interpretation: Hypertension defined as systolic >= 140 or diastolic >= 90 mmHg (ESC 2024), based on each patient's most recent reading. Living patients only.
SQL:
WITH bp AS (
  SELECT
    PATIENT,
    DATE,
    MAX(CASE WHEN DESCRIPTION = 'Systolic Blood Pressure' THEN value_num END) AS systolic,
    MAX(CASE WHEN DESCRIPTION = 'Diastolic Blood Pressure' THEN value_num END) AS diastolic
  FROM lab_results
  WHERE DESCRIPTION IN ('Systolic Blood Pressure', 'Diastolic Blood Pressure')
  GROUP BY PATIENT, DATE
),
latest AS (
SELECT 
  PATIENT, 
  MAX(DATE) AS last_date
  FROM bp
  GROUP BY PATIENT),

last_results AS (  
  SELECT
  bp.*
  FROM bp
  INNER JOIN latest
  ON bp.PATIENT = latest.PATIENT
  AND bp.date = latest.last_date)
  
  SELECT
  COUNT(l.PATIENT)
  FROM last_results AS l
  INNER JOIN patients AS p
  ON l.PATIENT = p.id
  WHERE (systolic >= 140 OR diastolic >= 90)
 AND (p.DEATHDATE IS NULL OR p.DEATHDATE = '')
 Expected result: 101

## Q9
Question: What is the average latest HbA1c value among patients diagnosed with diabetes?
Difficulty: hard
Interpretation: Diabetes = condition 'Diabetes' (prediabetes excluded). Latest HbA1c per patient. Note: Synthea A1c values in this sample are not clinically realistic (diabetic average lower than population average).
SQL:
WITH diabetic AS (
  SELECT DISTINCT PATIENT
  FROM conditions
  WHERE DESCRIPTION = 'Diabetes'
),
a1c AS (
  SELECT PATIENT, DATE, value_num
  FROM lab_results
  WHERE DESCRIPTION = 'Hemoglobin A1c/Hemoglobin.total in Blood'
),
latest AS (
  SELECT PATIENT, MAX(DATE) AS last_date
  FROM a1c
  GROUP BY PATIENT
)
SELECT AVG(a.value_num)
FROM a1c a
INNER JOIN latest lt ON a.PATIENT = lt.PATIENT AND a.DATE = lt.last_date
INNER JOIN diabetic d ON a.PATIENT = d.PATIENT;
Expected result: 4.99178082191781

## Q10
Question: How many patients have had elevated blood glucose but have never been diagnosed with diabetes?
Difficulty: hard
Interpretation: Elevated glucose = at least one reading >= 100 mg/dL (lower bound of impaired fasting glucose), fasting status unknown. Patients with prediabetes count as not diagnosed with diabetes. Threshold lowered from 126 because no patient above 126 lacks a diabetes diagnosis in this synthetic dataset.
SQL:
WITH high_glucose AS (
SELECT
DISTINCT(PATIENT) AS PATIENT
FROM lab_results
WHERE UNITS = 'mg/dL'
AND DESCRIPTION = 'Glucose'
AND value_num >= 100)

SELECT
COUNT(*)
FROM high_glucose h
WHERE NOT EXISTS (
	SELECT  1
	FROM conditions c
	WHERE c.PATIENT = h.PATIENT
		AND c.DESCRIPTION = 'Diabetes')
Expected result: 10
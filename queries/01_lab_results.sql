--create table lab_results
CREATE TABLE lab_results AS
SELECT
    DATE,
    PATIENT,
    CODE,
    DESCRIPTION,
    CAST(VALUE AS REAL) AS value_num,
    UNITS
FROM observations
WHERE TYPE = 'numeric';
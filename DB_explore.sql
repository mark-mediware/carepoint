-- Database Exploration for table information/data

-- filetype: SQL Server (T-SQL)

SELECT TOP(100) 
* 
FROM staging.dbo.Patient
;
--Patient contains basic demographics like name, SSN, gender (1 = male), DOB, MRN, Patientid (key), 

SELECT COUNT(DISTINCT PatientKey)
from staging.dbo.Patient
-- 58 million people...


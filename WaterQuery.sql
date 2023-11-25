---1)WHAT IS THE NAME OF CUSTOMER WITH ID "CUSTOOO2"

SELECT FullName
FROM ['Customer Details$']
WHERE CustomerID = 'CUST0002' AND LatestRecord = 'Y'


---2) WHAT IS THE AVERGAE TURBIDITY FOR EACH FACILITY IN THE FIRST 6 MONTHS?

SELECT F.FacilityName, ROUND(AVG(Turbidity_Level),2) AS 'Avg Turbidity'
FROM Quality$  Q
JOIN Facility$ F
ON Q.FacilityID = F.FacilityID
WHERE ReportDate  BETWEEN '2023-01-31' AND '2023-06-30'
GROUP BY FacilityName


----3)  WHICH FACILITY RECORDED THE HIGHEST CHLORINE LEVEL IN THE MONTH OF APRIL?

WITH Fac_Chlorine_IN_APRIL
AS
	(SELECT F.FacilityName, Q.Chlorine_Lvl
	FROM Facility$ F
	JOIN Quality$ Q
	ON F.FacilityID = Q.FacilityID
	WHERE DATENAME(MONTH,ReportDate) = 'April'
	)
SELECT TOP 1 FacilityName, Chlorine_lvl
from Fac_Chlorine_IN_APRIL
ORDER BY FacilityName Desc

------ OR THIS:

SELECT  TOP 1 FacilityName, max(Chlorine_lvl) AS CH
fROM Quality$ Q
JOIN Facility$ F
ON Q.FacilityID = F.FacilityID
WHERE ReportDate BETWEEN '2023-04-01' AND '2023-04-30'
GROUP BY FacilityName
ORDER BY CH Desc

		

----4) WHICH MONTH RECORD HIGHEST WATER CONSUMPTION
WITH HighestConsumptionMonth
AS
	(SELECT DATENAME(MONTH,ReportDate) AS Month_Name, ConsumptionRecord
	FROM Consumption$
	)

	SELECT TOP 1 Month_Name, SUM(ConsumptionRecord) AS TotalConsumption
	FROM HighestConsumptionMonth
	GROUP BY Month_Name
	ORDER BY TotalConsumption Desc

---5) WHICH CUSTOMER TYPE COUNSUMES THE LEAST AMOUNT OF WATER

WITH CustomerWithLeastConsumption
AS 
	( SELECT TOP 1 CustomerType, SUM(ConsumptionRecord) AS TotalConsumption
	FROM Consumption$
	GROUP BY CustomerType
	ORDER BY SUM(ConsumptionRecord)
	)

	SELECT CustomerType$.Value, TotalConsumption
	FROM CustomerWithLeastConsumption
	INNER JOIN CustomerType$
	ON CustomerWithLeastConsumption.CustomerType = CustomerType$.CustomerType

---6) HOW MUCH WATER DOES "BIG BEAR TREATMENT PLANT" SUPPLY TO "CITY OF EDMONTON" BY EACH MONTH

WITH CalcBigBearPlant
AS 
	( SELECT ReportDate, ConsumptionRecord
	FROM Consumption$
	INNER JOIN Facility$
	ON Facility$.FacilityID = Consumption$.FacilityID
	INNER JOIN ['Customer Details$']
	ON ['Customer Details$'].CustomerID = Consumption$.CustomerID
	WHERE Facility$.FacilityName = 'Big Bear Treatment Plant' AND ['Customer Details$'].FullName = 'City of Edmonton' AND Facility$.LatestRecord = 'Y'
	)

	SELECT DATENAME(MONTH, ReportDate) AS MONTH_NAME, SUM(ConsumptionRecord) AS
	TotalSupplyByBigBearPlant
	FROM CalcBigBearPlant
	GROUP BY DATENAME(MONTH, ReportDate), ReportDate
	ORDER BY ReportDate

----7) WHICH FACILITY RECORDED CONSUMPTION 95% OF ITS MAXIMUM CAPACITY AND FOR HOW MANY CONSECUTIVES MONTHS?

WITH ConsumptionPerFacility
AS
	(SELECT FacilityName, ReportDate, ConsumptionRecord, MaxiumCapacity
	FROM Consumption$
	INNER JOIN Facility$
	ON Facility$.FacilityID = Consumption$.FacilityID
	INNER JOIN ['Customer Details$']
	ON ['Customer Details$'].CustomerID = Consumption$.CustomerID
	)

	SELECT FacilityName, DATENAME(MONTH, ReportDate) AS Month_Name, 
	SUM(ConsumptionRecord)AS TotalConsumption, MaxiumCapacity, ROW_NUMBER() OVER (PARTITION BY FacilityName ORDER BY ReportDate) AS ConsecutiveMonths
	FROM ConsumptionPerFacility
	GROUP BY FacilityName, DATENAME(MONTH, ReportDate), MaxiumCapacity, ReportDate
	Having SUM(ConsumptionRecord) >= (0.9 * MaxiumCapacity)




----8) HOW MUCH WATER DOES "NEIGHBOURHOOD 1" RECEIVES FROM "JANE DOE TREATMENT PLANT" IN MARCH 2023

SELECT SUM(ConsumptionRecord) AS 'Total Neigbhourhood 1 Supply From Jane Doe in March 2023'
FROM Property$
INNER JOIN Consumption$
ON Property$.[Property ID] = Consumption$.PropertyID
INNER JOIN Facility$
ON Facility$.FacilityID = Consumption$.FacilityID
WHERE Property$.Neighbourhood = 'Neighbourhood 1' AND Facility$.FacilityName = 'Jane Doe Treatment Plant'
AND ReportDate BETWEEN '2023-03-01' AND '2023-03-31'



----9) Rank the Customers based on their total water consumption

SELECT FullName, Sum(ConsumptionRecord) AS TotalConsumption, RANK() OVER
(ORDER BY SUM(ConsumptionRecord) Desc) AS Ranking
FROM ['Customer Details$']
INNER JOIN Consumption$
ON Consumption$.CustomerID = ['Customer Details$'].CustomerID
GROUP BY FullName











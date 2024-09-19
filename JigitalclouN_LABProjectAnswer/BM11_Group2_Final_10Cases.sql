--10 CASES BY GROUP 2 BM11

--1
SELECT ms.StaffID, StaffName, StaffGender, StaffSalary, LongestPeriod = MAX(RentalDuration)
FROM MsStaff ms
JOIN RentalTransactionHeader rth
ON ms.StaffID = rth.StaffId
JOIN MsCustomer mc
ON rth.CustID = mc.CustId
WHERE StaffSalary < 15000000
  AND DATEDIFF(YEAR, CustDOB, GETDATE()) < 20
GROUP BY ms.StaffID, StaffName, StaffGender, StaffSalary

--2
SELECT 'Location' = CONCAT(LocCity , ' ' , LocCountry), 'CheapestServicePrice' =  MIN(ServerPrice)
FROM MsLocation ml
JOIN MsServer ms
ON ml.LocId = ms.LocId 
JOIN MsProcessor mp 
ON mp.ProcessorId = ms.ProcessorId
WHERE ProcessorClock > 3000
  AND LocLatitude BETWEEN -30 AND 30
GROUP BY CONCAT(LocCity , ' ' , LocCountry)

--3
SELECT rth.RentID , 'MaxMemoryFrequency' = CONCAT(MAX(MemoryFreq), 'MHz'), 'TotalMemoryCapacity' = CONCAT(SUM(MemoryCapacity), 'GB')
FROM RentalTransactionHeader rth JOIN RentalTransactionDetail rtd ON rth.RentID = rtd.RentID
JOIN MsServer ms ON rtd.ServerID = ms.ServerID
JOIN MsMemory mm ON ms.MemoryID = mm.MemoryID
WHERE DATENAME(Quarter, RentStartDate) = 4 AND YEAR(RentStartDate) = 2020
GROUP BY rth.RentID

--4
SELECT std.SalesID, 'ServerCount' = COUNT(std.ServerID), 
	'AverageServerPrice' = CONCAT(AVG(ServerPrice)/1000000, ' million(s) IDR')
FROM SalesTransactionHeader sth JOIN SalesTransactionDetail std
ON sth.SalesID = std.SalesID
JOIN MsServer ms 
ON std.ServerID = ms.ServerID
WHERE YEAR(TransactionDate) BETWEEN 2016 AND 2020
GROUP BY std.SalesID
HAVING AVG(ServerPrice) > 50000000

--5
SELECT TOP(10) sth.SalesID, 'MostExpensiveServerPrice' = MAX(ms.ServerPrice), 
	'HardwareRatingIndex' = ROUND(((0.55 * ProcessorClock * ProcessorCores) + (MemoryFreq * MemoryCapacity * 0.05))/ 143200, 3)
FROM SalesTransactionHeader sth JOIN SalesTransactionDetail std
ON sth.SalesID = std.SalesID
JOIN MsServer ms 
ON std.ServerID = ms.ServerID
JOIN MsProcessor mp 
ON ms.ProcessorID = mp.ProcessorID
JOIN MsMemory mm 
ON ms.MemoryID = mm.MemoryID,
	(SELECT ServerPrice 
	FROM MsServer ms JOIN SalesTransactionDetail std
	ON ms.ServerID = std.ServerID
	JOIN SalesTransactionHeader sth
	ON std.SalesID = sth.SalesID
	WHERE YEAR(TransactionDate) % 2 = 1
	GROUP BY ms.ServerPrice) AS alias
WHERE ms.ServerPrice = alias.ServerPrice
GROUP BY sth.SalesID, ROUND(((0.55 * ProcessorClock * ProcessorCores) + (MemoryFreq * MemoryCapacity * 0.05))/ 143200, 3)

--6
SELECT DISTINCT 'ProcessorName' = CONCAT(LEFT(ProcessorName, CHARINDEX(' ', ProcessorName)), ' ', ProcessorCode), 
	'CoreCount' = CONCAT(mp.ProcessorCores, ' core(s)'),
	'ProcessorPriceIDR' = ProcessorPrice
FROM MsProcessor mp,
	(SELECT mp.ProcessorCores, 'MostExpensive' = MAX(ProcessorPrice)
	FROM MsProcessor mp JOIN MsServer ms
	ON mp.ProcessorID = ms.ProcessorID
	JOIN MsLocation ml
	ON ms.LocID = ml.LocID
	WHERE LocLatitude BETWEEN 0 AND 90
	GROUP BY mp.ProcessorCores) AS alias
WHERE ProcessorPrice = alias.MostExpensive
AND mp.ProcessorCores = alias.ProcessorCores

--7
SELECT TOP (10) 
CONCAT(LEFT(mc.CustName, 1), '***** *****') AS 'HiddenCustomerName', 
CurrentPurchaseAmount, 
CountedPurchaseAmount, 
CONCAT(SUM(ServerPrice) / 1000000, ' point(s)') AS 'RewardPointsGiven'
FROM SalesTransactionHeader sth JOIN MsCustomer mc ON mc.CustID = sth.CustID
JOIN SalesTransactionDetail std ON sth.SalesID = std.SalesID
JOIN MsServer ms ON std.ServerID = ms.ServerID,(
	SELECT mc.CustID, COUNT(SalesID) AS CurrentPurchaseAmount
	FROM SalesTransactionHeader sh JOIN MsCustomer mc ON sh.CustID = mc.CustID
	GROUP BY mc.CustID) x,
	(
	SELECT mc.CustID, COUNT(SalesID) AS CountedPurchaseAmount
	FROM SalesTransactionHeader sh JOIN MsCustomer mc ON sh.CustID = mc.CustID
	WHERE YEAR(TransactionDate) BETWEEN 2015 AND 2019
	GROUP BY mc.CustID
	) y
WHERE mc.CustID = x.CustID AND mc.CustID = y.CustID AND YEAR(TransactionDate) BETWEEN 2015 AND 2019
GROUP BY mc.CustID, mc.CustName, x.CurrentPurchaseAmount, y.CountedPurchaseAmount


--8
SELECT 
	'StaffName' = CONCAT('Staff ', LEFT(StaffName, CHARINDEX(' ', StaffName))),
	'StaffEmail' = SUBSTRING(StaffEmail, 1, CHARINDEX('@', StaffEmail)) + 'jigitalcloun.net',
	 StaffAddress,
	'StaffSalary' = CONCAT(StaffSalary/10000000, ' million(s) IDR'),
	'TotalValue' = SUM(ServerPrice/120*RentalDuration)
FROM MsStaff ms 
JOIN RentalTransactionHeader rth ON rth.StaffID = ms.StaffID
JOIN RentalTransactionDetail rtd ON rtd.RentID = rth.RentID
JOIN MsServer mse ON mse.ServerID = rtd.ServerID,
(
SELECT 
	AVG(StaffSalary) AS [Average]
FROM MsStaff
)x
WHERE StaffSalary < x.Average
GROUP BY CONCAT('Staff ', LEFT(StaffName, CHARINDEX(' ', StaffName))), SUBSTRING(StaffEmail, 1, CHARINDEX('@', StaffEmail)) + 'jigitalcloun.net', 
StaffAddress, CONCAT(StaffSalary/10000000, ' million(s) IDR')
HAVING SUM(ServerPrice / 120 * RentalDuration) > 10000000

--9
CREATE VIEW ServerRentalDurationView
AS
SELECT 'Server' = REPLACE(ms.ServerID, 'JCN-V','No. '), 
'TotalRentalDuration' = CONCAT(SUM(RentalDuration), ' month(s)'), 
'MaxSingleDuration' = CONCAT(MAX(RentalDuration), ' month(s)')
FROM MsLocation ml 
JOIN MsServer ms ON ml.LocID = ms.LocID
JOIN RentalTransactionDetail rtd ON ms.ServerID = rtd.ServerID
JOIN RentalTransactionHeader rth ON rtd.RentID = rth.RentID
WHERE LocLatitude BETWEEN -90 AND 0
GROUP BY REPLACE(ms.ServerID, 'JCN-V','No. ')
HAVING SUM(RentalDuration) > 50
GO

SELECT *
FROM ServerRentalDurationView

--10
CREATE VIEW SoldProcessorPerformanceView
AS
SELECT SalesID, 'MinEffectiveClock' = CONCAT(ROUND(MIN(ProcessorClock*ProcessorCores*0.675), 1), ' MHz'),
'MaxEffectiveClock' = CONCAT(ROUND(MAX(ProcessorClock*ProcessorCores*0.675), 1), ' MHz')
FROM MsProcessor mp JOIN MsServer ms ON mp.ProcessorID = ms.ProcessorID
JOIN SalesTransactionDetail std ON ms.ServerID = std.ServerID
WHERE ProcessorCores = POWER(2, FLOOR(LOG(ProcessorCores, 2)))
GROUP BY SalesID
HAVING ROUND(MIN(ProcessorClock*ProcessorCores*0.675), 1) >= 10000
GO

SELECT *
FROM SoldProcessorPerformanceView






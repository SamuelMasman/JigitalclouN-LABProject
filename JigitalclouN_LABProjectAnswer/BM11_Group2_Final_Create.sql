CREATE DATABASE JigitalclouN_G2
GO

USE JigitalclouN_G2
GO

CREATE TABLE MsLocation(
	LocID VARCHAR(10) PRIMARY KEY, CHECK(LocID LIKE 'JCN-L[3-7][1-2][0-9][0-9]'),
	LocCity VARCHAR(30) NOT NULL,
	LocCountry VARCHAR(30) NOT NULL,
	LocZip INT NOT NULL,
	LocLatitude DECIMAL(9, 6) NOT NULL, CHECK(LocLatitude BETWEEN -90 AND 90),
	LocLongitude DECIMAL(9, 6) NOT NULL, CHECK(LocLongitude BETWEEN -180 AND 180)
)



CREATE TABLE MsMemory (
	MemoryID VARCHAR(10) PRIMARY KEY, CHECK(MemoryID LIKE 'JCN-M[3-7][1-2][0-9][0-9]'),
	MemoryName VARCHAR(255) NOT NULL,
	MemoryCode CHAR(10) NOT NULL,
	MemoryPrice INT NOT NULL,
	MemoryFreq INT NOT NULL, CHECK(MemoryFreq BETWEEN 1000 AND 5000),
	MemoryCapacity INT NOT NULL, CHECK(MemoryCapacity BETWEEN 1 AND 256),
)



CREATE TABLE MsCustomer(
	CustID VARCHAR(10) PRIMARY KEY CHECK(CustID LIKE 'JCN-C[3-7][1-2][0-9][0-9]'),
	CustName VARCHAR(255) NOT NULL,
    CustGender VARCHAR(255) NOT NULL, CHECK(CustGender IN ('Male', 'Female')),
   	CustEmail VARCHAR(255) NOT NULL,
	CustDOB DATE NOT NULL, CHECK(DATEDIFF(YEAR, CustDOB, GETDATE()) >= 15),
	CustPhone CHAR(12) NOT NULL,
	CustAddress VARCHAR(255) NOT NULL,
)



CREATE TABLE MsStaff (
	StaffID VARCHAR(10) PRIMARY KEY, CHECK(StaffID LIKE 'JCN-S[3-7][1-2][0-9][0-9]'),
	StaffName VARCHAR(255) NOT NULL,
	StaffGender VARCHAR(255) NOT NULL,
	StaffEmail VARCHAR(255) NOT NULL, CHECK(StaffEmail LIKE '%@%.%'),
	StaffDOB DATE NOT NULL,
	StaffPhone CHAR(12) NOT NULL,
	StaffAddress VARCHAR(255) NOT NULL,
	StaffSalary INT NOT NULL, CHECK(StaffSalary > 3500000 AND StaffSalary < 20000000)
)



CREATE TABLE MsProcessor (
	ProcessorID VARCHAR(10) PRIMARY KEY CHECK(ProcessorID LIKE 'JCN-P[3-7][1-2][0-9][0-9]'),
	ProcessorName VARCHAR(255) NOT NULL,
	ProcessorCode CHAR(10) NOT NULL,
	ProcessorPrice INT NOT NULL,
	ProcessorClock INT NOT NULL, CHECK(ProcessorClock BETWEEN 1500 AND 6000),
	ProcessorCores INT NOT NULL, CHECK(ProcessorCores BETWEEN 1 AND 24)
)


	
CREATE TABLE MsServer (
	ServerID VARCHAR(10) PRIMARY KEY CHECK(ServerID LIKE 'JCN-V[3-7][1-2][0-9][0-9]'),
	MemoryID VARCHAR(10) NOT NULL REFERENCES MsMemory(MemoryID),
	ProcessorID VARCHAR(10) NOT NULL REFERENCES MsProcessor(ProcessorID),
	LocID VARCHAR(10) NOT NULL REFERENCES MsLocation(LocID),
	ServerPrice INT NOT NULL
)



CREATE TABLE SalesTransactionHeader (
	SalesID VARCHAR(10) PRIMARY KEY, CHECK(SalesID LIKE 'JCN-S[0-2][1-2][0-9][0-9]'),
	CustID VARCHAR(10) NOT NULL REFERENCES MsCustomer(CustID),
	StaffID VARCHAR(10) NOT NULL REFERENCES MsStaff(StaffID),
	TransactionDate DATE NOT NULL
)




CREATE TABLE SalesTransactionDetail (
	SalesID VARCHAR(10) NOT NULL REFERENCES SalesTransactionHeader(SalesID),
	ServerID VARCHAR(10) NOT NULL REFERENCES MsServer (ServerID),
	SalesSold INT NOT NULL
)



CREATE TABLE RentalTransactionHeader (
	RentID VARCHAR(10) PRIMARY KEY, CHECK(RentID LIKE 'JCN-R[0-2][1-2][0-9][0-9]'),
	StaffID VARCHAR(10) NOT NULL REFERENCES MsStaff(StaffID),
	CustID VARCHAR(10) NOT NULL REFERENCES MsCustomer(CustID),
	RentStartDate DATE NOT NULL, CHECK(RentStartDate BETWEEN '2012-01-01' AND GETDATE()),
	RentalDuration INT NOT NULL
)


CREATE TABLE RentalTransactionDetail (
	RentID VARCHAR(10) NOT NULL REFERENCES RentalTransactionHeader(RentID),
	ServerID VARCHAR(10) NOT NULL REFERENCES MsServer(ServerID),
	ServerRented INT NOT NULL
)

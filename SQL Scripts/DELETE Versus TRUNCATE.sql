/*************************************************************
*                                                            *
*   Copyright (C) Microsoft Corporation. All rights reserved.*
*                                                            *
*************************************************************/

-- Flush and Fill: Delete vs Truncate
 USE [DWAdventureWorksLT2014v1]
 go

-- Scenario:  Each day we fill the DimCustomers table with current data
INSERT INTO [DWAdventureWorksLT2014v1].[dbo].[DimCustomers]
( [CustomerID]
, [ContactFullName]
, [CompanyName]
, [MainOfficeCity]
, [MainOfficeStateProvince]
, [MainOfficeCountryRegion]
)
SELECT 
	  [CustomerID] = T1.CustomerID
	, [CompanyName] = T8.Name
	, [ContactFullName] = Cast([FirstName] + ' ' + [LastName] as nvarchar(200))
	, [MainOfficeCity] = T5.City
    , [MainOfficeStateProvince] = T7.[StateProvinceName] 
    , [MainOfficeCountryRegion] = T7.[CountryRegionName]

FROM [AdventureWorks2014].[Sales].[Customer] as T1
JOIN  [AdventureWorks2014].[Person].[Person] as T2
	On T1.[PersonID] = T2.[BusinessEntityID]
JOIN  [AdventureWorks2014].Person.[BusinessEntityAddress] as T3
	On T2.BusinessEntityID = T3.BusinessEntityID
JOIN  [AdventureWorks2014].Person.BusinessEntityAddress as T4
	On T3.BusinessEntityID = T4.BusinessEntityID
JOIN  [AdventureWorks2014].[Person].[Address] as T5
	On T4.AddressID= T5.AddressID
JOIN  [AdventureWorks2014].Person.AddressType as T6
	On T4.AddressTypeID = T6.AddressTypeID
Join  [AdventureWorks2014].[Person].[vStateProvinceCountryRegion] T7
	On T5.StateProvinceID = T7.StateProvinceID
Join  [AdventureWorks2014].[Sales].[Store] T8
	On T8.SalesPersonID = T1.PersonID
--WHERE T6.Name= 'Main Office';
go

-- Current Data In DimCustomers 
SELECT 
	 [CustomerKey]
	,[CustomerID]
	,[ContactFullName]
	,[CompanyName]
	,[MainOfficeCity]
	,[MainOfficeStateProvince]
	,[MainOfficeCountryRegion]
FROM [DWAdventureWorksLT2014v1].[dbo].[DimCustomers]
go

-- Now let's Flush the data to prepare for new data using the SQL Delete statement
DELETE FROM dbo.DimCustomers;
go


-- Now let's Flush the data to prepare for new data using the SQL Truncate statement
TRUNCATE TABLE dbo.DimCustomers;
go

ALTER TABLE dbo.FactSales DROP CONSTRAINT 
	fkFactSalesToDimCustomers;
go

TRUNCATE TABLE dbo.DimCustomers;
go


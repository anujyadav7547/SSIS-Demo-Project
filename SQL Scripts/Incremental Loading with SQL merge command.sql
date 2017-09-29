--( Incremental Loading with merge )--
--'********************************************************************************************'

Use TempDB;
Go


-- ResetDemo -- 
	If (object_id('Customers') is not null) Drop Table Customers;
	Create
	Table Customers 
	( CustomerID int Primary Key Identity
	, CustomerName nVarchar(100)
	, CustomerEmail nVarchar(100) Unique);

	If (object_id('DimCustomers') is not null) Drop Table DimCustomers;
	Create
	Table DimCustomers 
	( CustomerID int Primary Key
	, CustomerName nVarchar(100)
	, CustomerEmail nVarchar(100));

	-- Now add some data to the first table. This will be our "SOURCE" table.
	Insert into Customers(CustomerName, CustomerEmail)
		Values ('Bob Smith' , 'BSmith@DemoCo.com')
			      , ('Sue Jones' , 'SJones@DemoCo.com');
go

-- Since we are going to compare the tables' data a lot, 
--- let's make a Stored Procedure like this one...
If (object_id('pCompareDifferences') is not null) Drop Procedure pCompareDifferences;
go
-- Create procedure to compare the two tables
create procedure pCompareDifferences
As

	Select * from Customers;
	Select * from dimCustomers;

Go

Merge into dimcustomers as TargetTable
	Using Customers as SourceTable
	on TargetTable.CustomerID = SourceTable.CustomerID
	When Matched -- ID in the source match with ID in the target
		AND ( SourceTable.CustomerName <> TargetTable.CustomerName  
		OR SourceTable.CustomerEmail <> TargetTable.CustomerEmail) 
		Then
			UPDATE -- change the data in the Target table (DimCustomers)
			SET TargetTable.CustomerName = SourceTable.CustomerName
					, TargetTable.CustomerEmail = SourceTable.CustomerEmail
	When Not Matched -- ID in the source does not match ID in the Target
		Then
			Insert 
			Values(SourceTable.CustomerID, SourceTable.CustomerName, SourceTable.CustomerEmail)
	When Not Matched By Source 
		Then -- The CustomerID is in the Target table, but not the source table
			DELETE
;
Go
Exec pCompareDifferences;
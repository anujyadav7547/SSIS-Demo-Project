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

-- Also, we can transfer data using a Flush and Fill Procedure like this one...
if(OBJECT_ID('pFlushAndFillDimCustomers') is not NULL)  drop procedure pFlushAndFillDimCustomers;
GO

CREATE PROCEDURE pFlushAndFillDimCustomers
AS
Delete from DimCustomers;

Insert into DimCustomers 
	Select * from Customers;

GO


-- Test the procedures 
Exec pCompareDifferences;
Exec pFlushAndFillDimCustomers;
Exec pCompareDifferences;

-- Update and report DW Proc
if(OBJECT_id('pUpdateAndReport') is not null) drop procedure  pUpdateAndReport;
GO
CREATE PROCEDURE pUpdateAndReport
AS
Exec pFlushAndFillDimCustomers;
Exec pCompareDifferences;
GO

-- CASE 1: When new Items are added to Customer table

Insert into Customers values ('Tim Thomas' , 'TThomas@DemoCo.com');
Exec pUpdateAndReport;

-- CASE 2: When customer detail is updated
if exists(select CustomerID from Customers where CustomerID = 3)
	Begin
		UPDATE Customers 
		set CustomerName = 'Anuj Yadav'
		WHere CustomerID = 3
	end

Exec pUpdateAndReport;

-- CASE 3: When customer is deleted

if exists(select CustomerID from Customers where CustomerID = 3)
	Delete from Customers where CustomerID = 3

Exec pUpdateAndReport;
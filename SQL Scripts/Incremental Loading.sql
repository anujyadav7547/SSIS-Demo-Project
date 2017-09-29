--( Incremental Loading )--
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

-- We can transfer data to the dimension table by using Insert statements combined with a EXCEPT predicate. 
if(OBJECT_ID('pInsertDifference') is not null) drop procedure pInsertDifference
Go
CREATE PROCEDURE pInsertDifference
AS

	WITH ChangedCustomer
	AS
	(
		Select * from Customers
		Except
		Select * from DimCustomers
	)

Insert into DimCustomers select * from ChangedCustomer;
GO


if(OBJECT_ID('pUpdateDifference') is not null) drop procedure pUpdateDifference
Go
CREATE PROCEDURE pUpdateDifference
AS

	WITH ChangedCustomer
	AS
	(
		Select * from Customers
		Except
		Select * from DimCustomers
	)

Update DimCustomers
	Set CustomerEmail = ( select CustomerEmail from  ChangedCustomer where DimCustomers.CustomerID = ChangedCustomer.CustomerID),
		customername = ( select CustomerName from  ChangedCustomer where DimCustomers.CustomerID = ChangedCustomer.CustomerID)
	where CustomerID = (select customerid from ChangedCustomer);
GO


if(OBJECT_ID('pDeleteDifference') is not null) drop procedure pDeleteDifference
Go
CREATE PROCEDURE pDeleteDifference
AS

	WITH ChangedCustomer
	AS
	(
		Select * from DimCustomers
		Except
		Select * from Customers
	)

Delete from DimCustomers
	where CustomerID = (select customerid from ChangedCustomer);
GO


EXEC pInsertDifference;
Exec pCompareDifferences;

-- Ok, so that works with an Insert but what about updates? --
Declare @CustomerID as int
-- Set @CustomerID = 2.5  ' this would be treated as 2
Set @CustomerID = 4 
if exists(select * from Customers where CustomerID = @CustomerID)
	Begin
		Update Customers 
		set CustomerName = 'Anuj Kumar Yadav'
		Where CustomerID = @CustomerID
	End
else
	Begin
		Print 'Customer not found'
	end

Exec pUpdateDifference
EXEC pCompareDifferences
GO


-- Now that we have the Insert and Update working, lets create a code for Deletes --

Declare @CustomerID as int
Set @CustomerID = 3 
if exists(select * from Customers where CustomerID = @CustomerID)
	Begin
		Delete From Customers Where CustomerID = @CustomerID;
	End
else
	Begin
		Print 'Customer not found'
	end
Exec pDeleteDifference
EXEC pCompareDifferences
GO


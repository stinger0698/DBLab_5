--TASK 1
USE AdventureWorks2012
GO
CREATE FUNCTION [Person].GetNumbers(@id int)  
RETURNS int   
AS 
BEGIN
	DECLARE @ret int
	SELECT @ret = COUNT(DISTINCT PhoneNumber)
	FROM Person.PersonPhone
	WHERE PhoneNumberTypeID = @id
	RETURN @ret;
END

--TASK 2
GO
CREATE FUNCTION [Person].[GetPersons](@id int) 
RETURNS TABLE
AS
RETURN
(
	SELECT *
	FROM person.Person AS Person
	JOIN 
	(
	SELECT BusinessEntityID as Entity, PhoneNumberTypeID
	FROM Person.PersonPhone
	) AS Phone
	ON Person.BusinessEntityID = Phone.Entity 
	WHERE PersonType = 'EM' AND Phone.PhoneNumberTypeID = @id
)

--TASK 3
GO 
SELECT * 
FROM Person.GetPersons(1)
CROSS APPLY Person.GetPersons(2)
A
CROSS APPLY Person.GetPersons(3)
B

SELECT * 
FROM Person.GetPersons(1)
OUTER APPLY Person.GetPersons(2)
A
OUTER APPLY Person.GetPersons(3)
B

--TASK 4
GO
CREATE FUNCTION [dbo].[NewGetPersons](@id int)
RETURNS @ret TABLE
(
	EmployeeID int primary key NOT NULL,  
	FirstName nvarchar(255) NOT NULL,  
	LastName nvarchar(255) NOT NULL
)
AS 
BEGIN
	INSERT INTO @ret (EmployeeID, FirstName, LastName)
	SELECT BusinessEntityID, FirstName, LastName
	FROM person.Person AS Person
	JOIN 
	(
	SELECT BusinessEntityID as Entity, PhoneNumberTypeID
	FROM Person.PersonPhone
	) AS Phone
	ON Person.BusinessEntityID = Phone.Entity 
	WHERE PersonType = 'EM' AND Phone.PhoneNumberTypeID != @id

	RETURN
END;
GO
ALTER FUNCTION [Person].[GetPersons](@id int)
RETURNS TABLE
RETURN 
(
	SELECT * FROM [dbo].[NewGetPersons](@id)
)
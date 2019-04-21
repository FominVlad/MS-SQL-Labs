--1.	�������� ��������� ���������, �� ��� ������� ���� ��������� ���� �������,
-- ��� �� ��-�������.
CREATE PROCEDURE spGetMyInfo AS
BEGIN
SELECT 'Fomin' AS Surname, 'Vladyslav' AS [Name], 'Vitalyevich' AS Patronymic
END

--2.	� ������� ���� Northwind �������� ��������� ���������, �� ������ ���������
--�������� �������� �������. � ��� ������� ��������� � ���������� �F� �� �����
--���������� �� �����������-����, � ��� ������������ ��������� �M� � ������. 
--� ������������ ������� ������� �� ����� ����������� ��� ��, �� �������� �� ���������.
ALTER PROCEDURE spGetEmployees @male nvarchar(1) AS
BEGIN
IF @male IN ('F', 'M')
	SELECT * FROM Employees
	WHERE TitleOfCourtesy IN (
	CASE
		WHEN @male = 'F' THEN ('Ms.')
		WHEN @male = 'F' THEN ('Mrs.')
		WHEN @male = 'M' THEN ('Mr.')
	END,
	CASE
		WHEN @male = 'F' THEN ('Mrs.')
	END)
ELSE
	SELECT 'Undefined param'
END

--3.	� ������� ���� Northwind �������� ��������� ���������, �� �������� �� ���������� 
--�� ������� �����. � ���� ���, ���� ����� �� ������ � ������� ���������� �� �������� ����.
CREATE PROCEDURE spGetOrders @FirstDate date = NULL, @SecondDate date = NULL AS
BEGIN
IF @FirstDate IS NOT NULL AND @SecondDate IS NOT NULL
	SELECT * FROM Orders
	WHERE OrderDate BETWEEN @FirstDate AND @SecondDate
ELSE
	SELECT * FROM Orders
	WHERE OrderDate = GETDATE()
END

--4.	� ������� ���� Northwind �������� ��������� ���������, �� � ��������� �� 
--���������� ��������� ������� �������� �������� �� ������ ��� �������� �� ���� 
--��������. ��������� ��������� ����������� �� ���� �� ���� ��������.
CREATE PROCEDURE spGetProducts @Category1 int, @Category2 int = NULL, @Category3 int = NULL,
	@Category4 int = NULL, @Category5 int = NULL AS
BEGIN
SELECT * FROM Products
WHERE CategoryID IN (@Category1, @Category2, @Category3, @Category4, @Category5)
END

--5.	� ������� ���� Northwind ������������ ��������� ��������� Ten Most Expensive Products 
--��� ������ �񳺿 ���������� � ������� ��������, � ����� ���� ������������� �� ����� ��������.
ALTER PROCEDURE [dbo].[Ten Most Expensive Products] AS
BEGIN
SELECT * FROM Products P JOIN (SELECT CompanyName, SupplierID FROM Suppliers) S 
ON P.SupplierID = S.SupplierID
JOIN (SELECT CategoryName, CategoryID FROM Categories) C ON P.CategoryID = C.CategoryID
END

--6.	� ������� ���� Northwind �������� �������, �� ������ ��� ��������� 
--(TitleOfCourtesy, FirstName, LastName) �� �������� �� ������ �������. 
--�������: �Dr.�, �Yevhen�, �Nedashkivskyi� �> �Dr. Yevhen Nedashkivskyi�
CREATE FUNCTION fnConcatArgs (@TitleOfCourtesy nvarchar(10), @FirstName nvarchar(35), 
	@LastName nvarchar(35)) 
RETURNS nvarchar(82) AS
BEGIN
RETURN CONCAT(@TitleOfCourtesy, ' ', @FirstName, ' ', @LastName)
END

--7.	� �������� ���� Northwind �������� �������, �� ������ ��� ��������� 
--(UnitPrice, Quantity, Discount) �� �������� ������ ����.
CREATE FUNCTION fnGetPrice (@UnitPrice float, @Quantity float, @Discount float)
RETURNS float AS
BEGIN
	RETURN (@UnitPrice * @Quantity - @UnitPrice * @Quantity * @Discount)
END

--8.	�������� �������, �� ������ �������� ���������� ���� � ��������� ���� �� 
--Pascal Case. �������: ̳� ��������� ��� �> ̳�������������
ALTER FUNCTION fnGetPascalCase (@Text nvarchar(3000))
RETURNS nvarchar(max)
BEGIN
	DECLARE @separator nvarchar(max);
	DECLARE @index INT;
	SET @separator = '%[^A-z�-�0-9 ]%';
	SET @index = PATINDEX(@separator, @Text);
	WHILE @index > 0
	BEGIN
		SET @Text = STUFF(@Text, @index, 1, ' ')	
		SET @index = PATINDEX(@separator, @Text)
	END
	RETURN (SELECT STRING_AGG(
		CONCAT(
		UPPER(SUBSTRING(value, 1, 1)),
		LOWER(SUBSTRING(value, 2, LEN(value)))), '')
		FROM STRING_SPLIT(@Text, ' '))
END

--9.	� ������� ���� Northwind �������� �������, �� � ��������� �� ������� �����, 
--������� �� ��� ��� ����������� � ������ �������.
CREATE FUNCTION fnGetInfoEmployee (@Country nvarchar(25))
RETURNS TABLE AS
	RETURN (SELECT * FROM Employees
	WHERE Country = @Country);

--10.	� ������� ���� Northwind �������� �������, �� � ��������� �� ���� ����������� 
--������ ������� ������ �볺���, ���� ���� ��������������.
CREATE FUNCTION fnGetClientsOnTCompany (@TCompany nvarchar(50))
RETURNS TABLE AS
	RETURN (SELECT C.* 
		FROM Customers C JOIN Orders O ON O.CustomerID = C.CustomerID 
		JOIN Shippers S ON S.ShipperID = O.ShipVia
		WHERE S.CompanyName = @TCompany);


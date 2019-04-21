--1.	Створити збережену процедуру, що при виклику буде повертати ваше прізвище,
-- ім’я та по-батькові.
CREATE PROCEDURE spGetMyInfo AS
BEGIN
SELECT 'Fomin' AS Surname, 'Vladyslav' AS [Name], 'Vitalyevich' AS Patronymic
END

--2.	В котексті бази Northwind створити збережену процедуру, що приймає текстовий
--параметр мінімальної довжини. У разі виклику процедури з параметром ‘F’ на екран
--виводяться усі співробітники-жінки, у разі використання параметру ‘M’ – чоловікі. 
--У протилежному випадку вивести на екран повідомлення про те, що параметр не розпізнано.
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

--3.	В котексті бази Northwind створити збережену процедуру, що виводить усі замовлення 
--за заданий період. В тому разі, якщо період не задано – вивести замовлення за поточний день.
CREATE PROCEDURE spGetOrders @FirstDate date = NULL, @SecondDate date = NULL AS
BEGIN
IF @FirstDate IS NOT NULL AND @SecondDate IS NOT NULL
	SELECT * FROM Orders
	WHERE OrderDate BETWEEN @FirstDate AND @SecondDate
ELSE
	SELECT * FROM Orders
	WHERE OrderDate = GETDATE()
END

--4.	В котексті бази Northwind створити збережену процедуру, що в залежності від 
--переданого параметру категорії виводить категорію та перелік усіх продуктів за цією 
--категорією. Дозволити можливість використати від однієї до п’яти категорій.
CREATE PROCEDURE spGetProducts @Category1 int, @Category2 int = NULL, @Category3 int = NULL,
	@Category4 int = NULL, @Category5 int = NULL AS
BEGIN
SELECT * FROM Products
WHERE CategoryID IN (@Category1, @Category2, @Category3, @Category4, @Category5)
END

--5.	В котексті бази Northwind модифікувати збережену процедуру Ten Most Expensive Products 
--для виводу всієї інформації з таблиці продуктів, а також імен постачальників та назви категорій.
ALTER PROCEDURE [dbo].[Ten Most Expensive Products] AS
BEGIN
SELECT * FROM Products P JOIN (SELECT CompanyName, SupplierID FROM Suppliers) S 
ON P.SupplierID = S.SupplierID
JOIN (SELECT CategoryName, CategoryID FROM Categories) C ON P.CategoryID = C.CategoryID
END

--6.	В котексті бази Northwind створити функцію, що приймає три параметри 
--(TitleOfCourtesy, FirstName, LastName) та виводить їх єдиним текстом. 
--Приклад: ‘Dr.’, ‘Yevhen’, ‘Nedashkivskyi’ –> ‘Dr. Yevhen Nedashkivskyi’
CREATE FUNCTION fnConcatArgs (@TitleOfCourtesy nvarchar(10), @FirstName nvarchar(35), 
	@LastName nvarchar(35)) 
RETURNS nvarchar(82) AS
BEGIN
RETURN CONCAT(@TitleOfCourtesy, ' ', @FirstName, ' ', @LastName)
END

--7.	В контексті бази Northwind створити функцію, що приймає три параметри 
--(UnitPrice, Quantity, Discount) та виводить кінцеву ціну.
CREATE FUNCTION fnGetPrice (@UnitPrice float, @Quantity float, @Discount float)
RETURNS float AS
BEGIN
	RETURN (@UnitPrice * @Quantity - @UnitPrice * @Quantity * @Discount)
END

--8.	Створити функцію, що приймає параметр текстового типу і приводить його до 
--Pascal Case. Приклад: Мій маленький поні –> МійМаленькийПоні
ALTER FUNCTION fnGetPascalCase (@Text nvarchar(3000))
RETURNS nvarchar(max)
BEGIN
	DECLARE @separator nvarchar(max);
	DECLARE @index INT;
	SET @separator = '%[^A-zА-я0-9 ]%';
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

--9.	В котексті бази Northwind створити функцію, що в залежності від вказаної країни, 
--повертає усі дані про співробітника у вигляді таблиці.
CREATE FUNCTION fnGetInfoEmployee (@Country nvarchar(25))
RETURNS TABLE AS
	RETURN (SELECT * FROM Employees
	WHERE Country = @Country);

--10.	В котексті бази Northwind створити функцію, що в залежності від імені транспортної 
--компанії повертає список клієнтів, якою вони обслуговуються.
CREATE FUNCTION fnGetClientsOnTCompany (@TCompany nvarchar(50))
RETURNS TABLE AS
	RETURN (SELECT C.* 
		FROM Customers C JOIN Orders O ON O.CustomerID = C.CustomerID 
		JOIN Shippers S ON S.ShipperID = O.ShipVia
		WHERE S.CompanyName = @TCompany);


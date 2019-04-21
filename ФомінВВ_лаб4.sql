USE Northwind
GO
--1.	������ ���� �� ����������� ������ �� ������� Intern.
INSERT INTO Employees (LastName, FirstName, Title, TitleOfCourtesy, 
BirthDate, HireDate, Address, City, PostalCode, Country, HomePhone, 
Extension, Notes, Salary)
VALUES ('Fomin', 'Vladyslav', 'Intern', 'Mr.', 
	'1999-11-10 00:00:00.000', '2019-03-05 00:00:00.000', 'V. Yarmoly 6\8',
	'Kyiv', '20300', 'Ukraine', '+380631733337', '1337', 'The best student all over the World!',
	'10000.00');

--2.	������ ���� ������ �� Director.
UPDATE Employees
SET Title = 'Director'
WHERE EmployeeID = 11;
--���
UPDATE Employees
SET Title = 'Director'
WHERE LastName = 'Fomin' AND FirstName = 'Vladyslav';

--3.	��������� ������� Orders � ������� OrdersArchive.
SELECT * INTO OrdersArchive
FROM Orders;

--4.	�������� ������� OrdersArchive.
TRUNCATE TABLE OrdersArchive;
--��� (� ������, ��� �� ��������� �� �� ������. ������� ���� �������)
DELETE FROM OrdersArchive;

--5.	�� ��������� ������� OrdersArchive, ��������� �� ����������� ��������.
INSERT INTO OrdersArchive
SELECT CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia,
Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry
FROM Orders;

--6.	� ������� OrdersArchive �������� �� ����������, �� ���� ������� ����������� �� ������.
DELETE FROM OrdersArchive
WHERE CustomerID IN (SELECT CustomerID FROM Customers
WHERE City = 'Berlin');

--7.	������ � ���� ��� �������� � ������� ������ �� ������ �����.
INSERT INTO Products (ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice,
UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued)
VALUES ('Vladyslav', 3, 2, '80kg box', '10.11', 10, 0, 0, 1),
	('IP-71', 2, 3, '31 boxes x 31 pieces', '1337.00', 31, 0, 0, 1);

--8.	������� ��������, �� �� ��������� � �����������, �� ���, �� ����� �� ������������.
UPDATE Products
SET Discontinued = 0
WHERE ProductID IN (SELECT ProductID FROM Products
EXCEPT
SELECT DISTINCT ProductID FROM [Order Details]);
--���
UPDATE Products
SET Discontinued = 0
WHERE ProductID NOT IN (SELECT ProductID FROM [Order Details]);

--9.	�������� ������� OrdersArchive.
DROP TABLE OrdersArchive;

--10.	�������� ���� Northwind.
DROP DATABASE Northwind;
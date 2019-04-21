--***������ �1:
USE Northwind
GO
--   �������� ������� ��������:
--1.	��������� ������ ������� ����� � �������, �� ������ ����� �� 2147483647 ������. 
--      �������� ��� ��� MS SQL Server �� �� ���� ���� (�� ������� ����).
--SELECT COUNT_BIG(*) FROM MyTable; -- MS SQL

--SELECT COUNT(*) FROM "MyTable"; -- Postgre

--2.	ϳ��������� ������� ����� ������� �� ��������� SQL.
SELECT LEN('Fomin');

--3.	� ����� � ���� ��������, ������, �� ��-������� ������� ������ �� ���� �_� (���� �����������).
SELECT REPLACE('Fomin Vladyslav Vittalievich', ' ', '_');

--4.	�������� ��������� ���� ���������� ������� ��������, �� ������ ������������ �ᒺ������ �� �� 
--      ����� ����� � ������� ����, �� ������ ����� ����� � ������� ������� �����������, �� �����������
--      � ��� �����, � ����� ������ � ����� ��������.
SELECT CONCAT(SUBSTRING(FirstName, 1, 2), SUBSTRING(Surname, 1, 4), '@fomin.com')
AS 'Email generator' FROM UsefsForEmail;

--5.	�� ��������� SQL ���������, � ���� ���� ������ �� ����������.
SELECT DATENAME(DW, '1999/11/10');

--***������ �2:
--   �������� ������� �������� � �������� ���� Northwind:
--1.	������� �� ���� �� ���������, �� ���������, �� ��������������, ����� ���� ������ � ������ ������ ������.
SELECT * FROM Categories FULL OUTER JOIN 
(Suppliers FULL OUTER JOIN Products ON Products.ProductID = Suppliers.SupplierID)
ON Products.CategoryID = Categories.CategoryID;

--2.	�������� �� ����������, �� ���� ������� � ���� 1988 ���� �� �� ���� ���������.
SELECT * FROM Orders WHERE ShippedDate IS NULL AND DATEPART("yyyy", OrderDate) = 1988
AND DATEPART("mm", OrderDate) = 04;

--3.	³������ ��� ����������, �� ���������� �� ������� �����.
SELECT * FROM Employees WHERE EmployeeID IN (SELECT DISTINCT Employees.EmployeeID FROM 
((Employees JOIN EmployeeTerritories ON Employees.EmployeeID = EmployeeTerritories.EmployeeID) 
JOIN Territories ON EmployeeTerritories.TerritoryID = Territories.TerritoryID) JOIN Region 
ON Territories.RegionID = Region.RegionID WHERE Region.RegionDescription = 'Northern');

--4.	���������� �������� ������� � ����������� ������ ��� ���������, �� ���� ������� �� ������� ����.
--SELECT * FROM (
SELECT SUM((UnitPrice * Quantity) - (UnitPrice * Quantity * Discount))
FROM (SELECT OrderID FROM Orders WHERE DATEPART("d", Orders.OrderDate) % 2 != 0) AS Ord
INNER JOIN [Order Details] ON [Order Details].OrderID = Ord.OrderID;

--5.	������ ������ ����������� ���������� � ��������� ����� 
--      (���������� �� ������� ����������, �� �������, �������, �� �������� ������).
SELECT TOP(1) ShipAddress FROM Orders JOIN
(SELECT OrderID, SUM((UnitPrice * Quantity) - (UnitPrice * Quantity * Discount))
AS SummPrice FROM [Order Details] GROUP BY OrderID)
AS OrdersPrices ON Orders.OrderID = OrdersPrices.OrderID
ORDER BY SummPrice DESC
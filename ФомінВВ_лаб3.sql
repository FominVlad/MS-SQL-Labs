--������ �1:
--�������� ������� ��������:
--1.	�������������� SELECT ����, ������� �� ����� ��� ���, 
--������� �� ��-������� ����� ������������ �������.
SELECT 'Vladyslav' AS FirstName
UNION ALL
SELECT 'Vitalievich Fomin' AS LastName;

--2.	��������� ������� ���������� ����� � ���� � ������� �� ��� ������ � ����, 
--������� �� ����� ;-) ���� �� ������ �� �� � ���, ��� :-D � ������������ �������.
SELECT CASE
WHEN 30 < ALL (SELECT TOP 31 ROW_NUMBER() OVER (ORDER BY object_id) FROM sys.objects) THEN ';-)'
ELSE ':-D'
END;

--3.	�� �������������� �������, ������� �� ����� ������� �� ��� ��� ����� �� 
--����� �� ��������� ���, ��� �� ������ ��� � ����������� ���� �����.

WITH GirlsFromIP71 (FirstName, LastName) AS
(SELECT 'Diana', 'Boloteniuk'
UNION ALL
SELECT 'Olga', 'Orel'
UNION ALL
SELECT 'Anastasia', 'Kaspruk')

SELECT FirstName, LastName FROM GirlsFromIP71
WHERE FirstName IN (SELECT FirstName FROM GirlsFromIP71 EXCEPT
(SELECT 'Viktoria'
UNION ALL
SELECT 'Vladyslava'
UNION ALL
SELECT 'Kateryna'
UNION ALL
SELECT 'Lesya'
UNION ALL
SELECT 'Kateryna'
UNION ALL
SELECT 'Alexandra'
UNION ALL
SELECT 'Anastasia'));

--4.	������� �� ����� � ������� Numbers (Number INT). ������� ����� �� 0 �� 9 
--�� �� ����� �������. ���� ����� �����, ��� ����� �� ������, �������� �� ��� ���.
SELECT
CASE
	WHEN numb = 1 THEN 'One'
	WHEN numb = 2 THEN 'Two'
	WHEN numb = 3 THEN 'Three'
	WHEN numb = 4 THEN 'Four'
	WHEN numb = 5 THEN 'Five'
	WHEN numb = 6 THEN 'Six'
	WHEN numb = 7 THEN 'Seven'
	WHEN numb = 8 THEN 'Eight'
	WHEN numb = 9 THEN 'Nine'
	ELSE numb
END
FROM Numbers;

--5.	������� ������� ���������� ����������� �ᒺ������ ��� ���� ����.
SELECT * FROM FirstTableName, SecondTableName;
SELECT * FROM FirstTableName CROSS JOIN SecondTableName;

--������ �2:
USE Northwind
GO
--�������� ������� �������� � �������� ���� Northwind:
--1.	������� �� ���������� �� �� ������ ��������. � ��������� �� �������������� 
--������ ��������, ������������ �� �� ����, �� ������� ������ ����, �������, ��� ��-�������.
SELECT OrderID,
CASE
	WHEN ShipVia = 1 THEN 'Vladyslav'
	WHEN ShipVia = 2 THEN 'Vitalievich'
	WHEN ShipVia = 3 THEN 'Fomin'
END
FROM Orders;

--2.	������� � ���������� ������� �� �����, �� ��������� � ������� �볺���, 
--����������, �� ����� �������� ���������.
SELECT Country FROM Customers
UNION
SELECT Country FROM Employees
UNION
SELECT ShipCountry FROM Orders
ORDER BY Country;

--3.	������� ������� �� ��� ����������, � ����� ������� ���������, �� �� 
--������� �� ������ ������� 1998 ����.
SELECT LastName, FirstName, COUNT(OrderDate) AS 'Orders count' FROM Orders O JOIN 
(SELECT EmployeeID, LastName, FirstName FROM Employees) E ON O.EmployeeID = E.EmployeeID
WHERE YEAR(OrderDate) = 1998 AND MONTH(OrderDate) = ANY 
(SELECT TOP 3 ROW_NUMBER() OVER (ORDER BY object_id) FROM sys.objects)
GROUP BY LastName, FirstName;

--4.	�������������� �TE ������ �� ����������, � �� ������� ��������, 
--���� �� ����� ����� 100 �������, ����� �� ���� ���� ������������ ������.

--���� �� ������� ���� � ����������, �� ������� ����������� � ��������,
--���� �� ����� ����� 100 �������, ����� �� ���� ���� ������������ ������.
WITH AllOrders AS (
SELECT OrderID
FROM [Order Details] AS OD JOIN Products ON OD.ProductID = Products.ProductID
GROUP BY OrderID
HAVING MAX(Discount) < (SELECT MAX(Discount) FROM [Order Details])
AND MIN(UnitsInStock) > 100)

SELECT * FROM AllOrders;


--���� �� ��������, �� � ���������� ������ ������� � ���� ��������, ��
--�� ������� ����������, ��� ��� ����'������ �� ���� ���� � 1 �������,
--����� �� ����� ����� 100 �������, ����� �� ����� ���� ������������ ������.
WITH AllOrders AS (
SELECT OrderID
FROM [Order Details] AS OD JOIN (
SELECT ProductID FROM Products WHERE UnitsInStock > 100) AS ProductsMoreHundred
ON OD.ProductID = ProductsMoreHundred.ProductID
WHERE Discount < (SELECT MAX(Discount) FROM [Order Details])
)
SELECT DISTINCT * FROM AllOrders;

--5.	������ ����� ��� ��������, �� �� ���������� � ��������� �����.
SELECT DISTINCT ProductName FROM Products
EXCEPT
SELECT DISTINCT ProductName FROM Products
JOIN [Order Details] OD ON Products.ProductID = OD.ProductID
JOIN Orders ON OD.OrderID = Orders.OrderID
JOIN Employees ON Orders.EmployeeID = Employees.EmployeeID
JOIN EmployeeTerritories ET ON ET.EmployeeID = Employees.EmployeeID
JOIN Territories ON ET.TerritoryID = Territories.TerritoryID
JOIN Region ON Territories.RegionID = Region.RegionID
WHERE RegionDescription = 'Southern';
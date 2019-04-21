-- ���� ��������� ³�������� --
-- ����� ��-71 --
USE Northwind
GO
-- 1.	������� �� ��������� ������� SELECT ��� �������, ��� �� ��-������� �� �����.
SELECT 'Fomin Vladyslav Vitalievich' AS 'About me';

-- 2.	������� �� ��� � ������� Products.
SELECT * FROM Products;

-- 3.	������ �� ����� �������� � 򳺿 � �������, ������ ���� ���������.
SELECT ProductName FROM Products 
WHERE Discontinued = 1;

-- 4.	������� �� ���� �볺��� �������� ��������.
SELECT DISTINCT City FROM Customers;

-- 5.	������� �� ����� �������-������������� � ������� ����������� ����������.
SELECT CompanyName FROM Shippers 
ORDER BY CompanyName DESC;

-- 6.	�������� �� ����� ���������, �������� ����� ��������� �� �� ���������� �����.
SELECT OrderID AS '1',
		ProductID AS '2',
		UnitPrice AS '3',
		Quantity AS '4',
		Discount AS '5'  FROM [Order Details];

-- 7.	������� �� �������� ����� �볺���, �� ����������� � ����� ����� ������ �������, ����, ��-�������.
SELECT ContactName FROM Customers WHERE 
	ContactName LIKE '[Ff]%' OR 
	ContactName LIKE '[Vv]%' OR 
	ContactName LIKE '[Vv]%';

-- 8.	�������� �� ����������, � ������� �������� ���� � �����.
SELECT * FROM Orders WHERE ShipAddress LIKE '% %';

-- 9.	������� ����� ��� ��������, �� ����������� �� ���� % ��� _, � ����������� �� ������� ����� ������ ����.
SELECT ProductName FROM Products WHERE ProductName LIKE '[%_]%[Vv]';

USE Northwind
GO
--1.	Додати себе як співробітника компанії на позицію Intern.
INSERT INTO Employees (LastName, FirstName, Title, TitleOfCourtesy, 
BirthDate, HireDate, Address, City, PostalCode, Country, HomePhone, 
Extension, Notes, Salary)
VALUES ('Fomin', 'Vladyslav', 'Intern', 'Mr.', 
	'1999-11-10 00:00:00.000', '2019-03-05 00:00:00.000', 'V. Yarmoly 6\8',
	'Kyiv', '20300', 'Ukraine', '+380631733337', '1337', 'The best student all over the World!',
	'10000.00');

--2.	Змінити свою посаду на Director.
UPDATE Employees
SET Title = 'Director'
WHERE EmployeeID = 11;
--Або
UPDATE Employees
SET Title = 'Director'
WHERE LastName = 'Fomin' AND FirstName = 'Vladyslav';

--3.	Скопіювати таблицю Orders в таблицю OrdersArchive.
SELECT * INTO OrdersArchive
FROM Orders;

--4.	Очистити таблицю OrdersArchive.
TRUNCATE TABLE OrdersArchive;
--Або (є різниця, але на результат це не вплине. Таблиця буде порожня)
DELETE FROM OrdersArchive;

--5.	Не видаляючи таблицю OrdersArchive, наповнити її інформацією повторно.
INSERT INTO OrdersArchive
SELECT CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia,
Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry
FROM Orders;

--6.	З таблиці OrdersArchive видалити усі замовлення, що були зроблені замовниками із Берліну.
DELETE FROM OrdersArchive
WHERE CustomerID IN (SELECT CustomerID FROM Customers
WHERE City = 'Berlin');

--7.	Внести в базу два продукти з власним іменем та іменем групи.
INSERT INTO Products (ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice,
UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued)
VALUES ('Vladyslav', 3, 2, '80kg box', '10.11', 10, 0, 0, 1),
	('IP-71', 2, 3, '31 boxes x 31 pieces', '1337.00', 31, 0, 0, 1);

--8.	Помітити продукти, що не фігурують в замовленнях, як такі, що більше не виробляються.
UPDATE Products
SET Discontinued = 0
WHERE ProductID IN (SELECT ProductID FROM Products
EXCEPT
SELECT DISTINCT ProductID FROM [Order Details]);
--Або
UPDATE Products
SET Discontinued = 0
WHERE ProductID NOT IN (SELECT ProductID FROM [Order Details]);

--9.	Видалити таблицю OrdersArchive.
DROP TABLE OrdersArchive;

--10.	Видатили базу Northwind.
DROP DATABASE Northwind;
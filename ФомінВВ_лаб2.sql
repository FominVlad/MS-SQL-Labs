--***Задача №1:
USE Northwind
GO
--   Виконати наступні завдання:
--1.	Необхідно знайти кількість рядків в таблиці, що містить більше ніж 2147483647 записів. 
--      Напишіть код для MS SQL Server та ще однієї СУБД (на власний вибір).
--SELECT COUNT_BIG(*) FROM MyTable; -- MS SQL

--SELECT COUNT(*) FROM "MyTable"; -- Postgre

--2.	Підрахувати довжину свого прізвища за допомогою SQL.
SELECT LEN('Fomin');

--3.	У рядку з своїм прізвищем, іменем, та по-батькові замінити пробіли на знак ‘_’ (нижнє підкреслення).
SELECT REPLACE('Fomin Vladyslav Vittalievich', ' ', '_');

--4.	Створити генератор імені електронної поштової скриньки, що шляхом конкатенації об’єднував би дві 
--      перші літери з колонки імені, та чотири перші літери з колонки прізвища користувача, що зберігаються
--      в базі даних, а також домену з вашим прізвищем.
SELECT CONCAT(SUBSTRING(FirstName, 1, 2), SUBSTRING(Surname, 1, 4), '@fomin.com')
AS 'Email generator' FROM UsefsForEmail;

--5.	За допомогою SQL визначити, в який день тиждня ви народилися.
SELECT DATENAME(DW, '1999/11/10');

--***Задача №2:
--   Виконати наступні завдання в контексті бази Northwind:
--1.	Вивести усі данні по продуктам, їх категоріям, та постачальникам, навіть якщо останні з певних причин відсутні.
SELECT * FROM Categories FULL OUTER JOIN 
(Suppliers FULL OUTER JOIN Products ON Products.ProductID = Suppliers.SupplierID)
ON Products.CategoryID = Categories.CategoryID;

--2.	Показати усі замовлення, що були зроблені в квітні 1988 року та не були відправлені.
SELECT * FROM Orders WHERE ShippedDate IS NULL AND DATEPART("yyyy", OrderDate) = 1988
AND DATEPART("mm", OrderDate) = 04;

--3.	Відібрати усіх працівників, що відповідають за північний регіон.
SELECT * FROM Employees WHERE EmployeeID IN (SELECT DISTINCT Employees.EmployeeID FROM 
((Employees JOIN EmployeeTerritories ON Employees.EmployeeID = EmployeeTerritories.EmployeeID) 
JOIN Territories ON EmployeeTerritories.TerritoryID = Territories.TerritoryID) JOIN Region 
ON Territories.RegionID = Region.RegionID WHERE Region.RegionDescription = 'Northern');

--4.	Вирахувати загальну вартість з урахуванням знижки усіх замовлень, що були здійснені на непарну дату.
--SELECT * FROM (
SELECT SUM((UnitPrice * Quantity) - (UnitPrice * Quantity * Discount))
FROM (SELECT OrderID FROM Orders WHERE DATEPART("d", Orders.OrderDate) % 2 != 0) AS Ord
INNER JOIN [Order Details] ON [Order Details].OrderID = Ord.OrderID;

--5.	Знайти адресу відправлення замовлення з найбільшою ціною 
--      (враховуючи усі позиції замовлення, їх вартість, кількість, та наявність знижки).
SELECT TOP(1) ShipAddress FROM Orders JOIN
(SELECT OrderID, SUM((UnitPrice * Quantity) - (UnitPrice * Quantity * Discount))
AS SummPrice FROM [Order Details] GROUP BY OrderID)
AS OrdersPrices ON Orders.OrderID = OrdersPrices.OrderID
ORDER BY SummPrice DESC
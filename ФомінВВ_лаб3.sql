--Задача №1:
--Виконати наступні завдання:
--1.	Використовуючи SELECT двічі, виведіть на екран своє ім’я, 
--прізвище та по-батькові одним результуючим набором.
SELECT 'Vladyslav' AS FirstName
UNION ALL
SELECT 'Vitalievich Fomin' AS LastName;

--2.	Порівнявши власний порядковий номер в групі з набором із всіх номерів в групі, 
--вивести на екран ;-) якщо він менший за усі з них, або :-D в протилежному випадку.
SELECT CASE
WHEN 30 < ALL (SELECT TOP 31 ROW_NUMBER() OVER (ORDER BY object_id) FROM sys.objects) THEN ';-)'
ELSE ':-D'
END;

--3.	Не використовуючи таблиці, вивести на екран прізвище та ім’я усіх дівчат своєї 
--групи за вийнятком тих, хто має спільне ім’я з студентками іншої групи.

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

--4.	Вивести усі рядки з таблиці Numbers (Number INT). Замінити цифру від 0 до 9 
--на її назву літерами. Якщо цифра більше, або менша за названі, залишити її без змін.
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

--5.	Навести приклад синтаксису декартового об’єднання для вашої СУБД.
SELECT * FROM FirstTableName, SecondTableName;
SELECT * FROM FirstTableName CROSS JOIN SecondTableName;

--Задача №2:
USE Northwind
GO
--Виконати наступні завдання в контексті бази Northwind:
--1.	Вивисти усі замовлення та їх службу доставки. В залежності від ідентифікатора 
--служби доставки, переіменувати її на таку, що відповідає вашому імені, прізвищу, або по-батькові.
SELECT OrderID,
CASE
	WHEN ShipVia = 1 THEN 'Vladyslav'
	WHEN ShipVia = 2 THEN 'Vitalievich'
	WHEN ShipVia = 3 THEN 'Fomin'
END
FROM Orders;

--2.	Вивести в алфавітному порядку усі країни, що фігурують в адресах клієнтів, 
--працівників, та місцях доставки замовлень.
SELECT Country FROM Customers
UNION
SELECT Country FROM Employees
UNION
SELECT ShipCountry FROM Orders
ORDER BY Country;

--3.	Вивести прізвище та ім’я працівника, а також кількість замовлень, що він 
--обробив за перший квартал 1998 року.
SELECT LastName, FirstName, COUNT(OrderDate) AS 'Orders count' FROM Orders O JOIN 
(SELECT EmployeeID, LastName, FirstName FROM Employees) E ON O.EmployeeID = E.EmployeeID
WHERE YEAR(OrderDate) = 1998 AND MONTH(OrderDate) = ANY 
(SELECT TOP 3 ROW_NUMBER() OVER (ORDER BY object_id) FROM sys.objects)
GROUP BY LastName, FirstName;

--4.	Використовуючи СTE знайти усі замовлення, в які входять продукти, 
--яких на складі більше 100 одиниць, проте по яким немає максимальних знижок.

--Якщо ми виводим лише ті замовлення, які повністю складаються з продуктів,
--яких на складі більше 100 одиниць, проте по яким немає максимальних знижок.
WITH AllOrders AS (
SELECT OrderID
FROM [Order Details] AS OD JOIN Products ON OD.ProductID = Products.ProductID
GROUP BY OrderID
HAVING MAX(Discount) < (SELECT MAX(Discount) FROM [Order Details])
AND MIN(UnitsInStock) > 100)

SELECT * FROM AllOrders;


--Якщо ми допускаєм, що в замовлення можуть входити й інші продукти, які
--не пройшли фільтрацію, але там обов'язково має бути хоча б 1 продукт,
--якого на складі більше 100 одиниць, проте по якому немає максимальних знижок.
WITH AllOrders AS (
SELECT OrderID
FROM [Order Details] AS OD JOIN (
SELECT ProductID FROM Products WHERE UnitsInStock > 100) AS ProductsMoreHundred
ON OD.ProductID = ProductsMoreHundred.ProductID
WHERE Discount < (SELECT MAX(Discount) FROM [Order Details])
)
SELECT DISTINCT * FROM AllOrders;

--5.	Знайти назви усіх продуктів, що не продаються в південному регіоні.
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
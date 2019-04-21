USE Northwind
GO
--1.	Вивести на екран імена усіх таблиць в базі даних та кількість рядків в них.
SELECT DISTINCT sys.tables.name, sys.partitions.rows
FROM sys.tables
JOIN sys.partitions
ON sys.partitions.object_id = sys.tables.object_id
ORDER BY sys.tables.name;

--2.	Видати дозвіл на читання бази даних Northwind усім користувачам вашої СУБД. 
--Код повинен працювати в незалежності від імен існуючих користувачів.
GRANT SELECT ON DATABASE::Northwind TO PUBLIC

--3.	За допомогою курсору заборонити користувачеві TestUser доступ до всіх таблиць
--поточної бази даних, імена котрих починаються на префікс ‘prod_’.
CREATE LOGIN TestUser
WITH PASSWORD = 'TestUser';

CREATE USER TestUser FOR LOGIN TestUser;  

DECLARE TestCursor CURSOR FOR 
SELECT sys.tables.[name] 
FROM sys.tables
WHERE sys.tables.[name] LIKE 'prod[_]%'

DECLARE @table nvarchar
OPEN TestCursor
WHILE(@@FETCH_STATUS = 0)
BEGIN
FETCH NEXT FROM TestCursor INTO @table
EXEC ('DENY SELECT ON ' + @table + ' TO TestUser')
END
CLOSE TestCursor

DEALLOCATE TestCursor;

--4.	Створити тригер на таблиці Customers, що при вставці нового телефонного номеру
--буде видаляти усі символи крім цифер.
CREATE FUNCTION setOnlyNumbers(@Temp varchar(255))
RETURNS varchar(255)
AS
BEGIN
    DECLARE @KeepValues AS varchar(50)
    SET @KeepValues = '%[^0-9]%'
    WHILE PATINDEX(@KeepValues, @Temp) > 0
        SET @Temp = STUFF(@Temp, PATINDEX(@KeepValues, @Temp), 1, '')
    RETURN @Temp
END

CREATE TRIGGER delSymbolFromNumber ON Customers
AFTER INSERT AS 
BEGIN
UPDATE Customers
SET Phone = dbo.setOnlyNumbers(Phone)
WHERE CustomerID IN (SELECT CustomerID FROM inserted)
END

--5.	Створити таблицю Contacts (ContactId, LastName, FirstName, PersonalPhone, 
--WorkPhone, Email, PreferableNumber). Створити тригер, що при вставці даних в таблицю 
--Contacts вставить в якості PreferableNumber WorkPhone якщо він присутній, або 
--PersonalPhone, якщо робочий номер телефона не вказано.
CREATE TABLE Contacts (
ContactId int NOT NULL IDENTITY(1,1) PRIMARY KEY,
LastName varchar(30) NOT NULL,
FirstName varchar(30) NOT NULL,
PersonalPhone varchar(15) NOT NULL,
WorkPhone varchar(15),
Email varchar(50),
PreferableNumber varchar(15)
);

CREATE FUNCTION ChoosePhone(@PersonalPhone varchar(15), @WorkPhone varchar(15))
RETURNS varchar(15)
BEGIN
	DECLARE @ReturnPhone varchar(15)
	SET @ReturnPhone = (SELECT
	CASE
		WHEN @WorkPhone IS NOT NULL THEN @WorkPhone
		ELSE @PersonalPhone
	END)
	RETURN @ReturnPhone
END

CREATE TRIGGER AddPhone ON Contacts
AFTER INSERT AS
BEGIN
UPDATE Contacts
SET PreferableNumber = dbo.ChoosePhone(PersonalPhone, WorkPhone)
WHERE ContactId IN (SELECT ContactId FROM inserted)
END

--6.	Створити таблицю OrdersArchive що дублює таблицію Orders та має додаткові атрибути 
--DeletionDateTime та DeletedBy. Створити тригер, що при видаленні рядків з таблиці 
--Orders буде додавати їх в таблицю OrdersArchive та заповнювати відповідні колонки.
SELECT * INTO OrdersArchive FROM Orders WHERE 1 < 1;

ALTER TABLE OrdersArchive
ADD DeletionDateTime date NOT NULL;
ALTER TABLE OrdersArchive
ADD DeletedBy nvarchar NOT NULL;

SET IDENTITY_INSERT OrdersArchive ON

CREATE TRIGGER Archiver ON Orders
AFTER DELETE AS
BEGIN
INSERT INTO OrdersArchive
(OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, 
ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, 
ShipCountry, DeletionDateTime, DeletedBy)
SELECT OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, 
ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, 
ShipCountry, GETDATE(), CURRENT_USER FROM deleted
END

--7.	Створити три таблиці: TriggerTable1, TriggerTable2 та TriggerTable3. Кожна з 
--таблиць має наступну структуру: TriggerId(int) – первинний ключ з автоінкрементом, 
--TriggerDate(Date). Створити три тригера. Перший тригер повинен при будь-якому записі 
--в таблицю TriggerTable1 додати дату запису в таблицю TriggerTable2. Другий тригер 
--повинен при будь-якому записі в таблицю TriggerTable2 додати дату запису в таблицю 
--TriggerTable3. Третій тригер працює аналогічно за таблицями TriggerTable3 та TriggerTable1. 
--Вставте один рядок в таблицю TriggerTable1. Напишіть, що відбулось в коментарі до коду. 
--Чому це сталося?
CREATE TABLE TriggerTable1(
TriggerId int NOT NULL IDENTITY(1,1) PRIMARY KEY,
TriggerDate date NOT NULL
);

CREATE TABLE TriggerTable2(
TriggerId int NOT NULL IDENTITY(1,1) PRIMARY KEY,
TriggerDate date NOT NULL
);

CREATE TABLE TriggerTable3(
TriggerId int NOT NULL IDENTITY(1,1) PRIMARY KEY,
TriggerDate date NOT NULL
);

CREATE TRIGGER TriggerT1 ON TriggerTable1
AFTER INSERT AS
BEGIN
INSERT INTO TriggerTable2 (TriggerDate)
VALUES (GETDATE())
END

CREATE TRIGGER TriggerT2 ON TriggerTable2
AFTER INSERT AS
BEGIN
INSERT INTO TriggerTable3 (TriggerDate)
VALUES (GETDATE())
END

CREATE TRIGGER TriggerT3 ON TriggerTable3
AFTER INSERT AS
BEGIN
INSERT INTO TriggerTable1 (TriggerDate)
VALUES (GETDATE())
END

INSERT INTO TriggerTable1
VALUES (GETDATE())

--Maximum stored procedure, function, trigger, or view nesting level exceeded (limit 32).
--При вставке в таблицу срабатывает триггер, который вызывает следующий триггер, и так
--получается рекурсия. Бесконечный вызов триггеров. По-этому переполнился стек, который
--ограничен 32 уровнями вложености level exceeded (limit 32).
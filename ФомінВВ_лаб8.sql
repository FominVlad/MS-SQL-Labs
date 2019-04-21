--1.	Створити базу даних підприємства «LazyStudent», що займається допомогою 
--студентам ВУЗів з пошуком репетиторів, проходженням практики та розмовними 
--курсами за кордоном.
CREATE DATABASE LazyStudent;

--2.	Самостійно спроектувати структуру бази в залежності від наступних завдань.

--3.	База даних повинна передбачати реєстрацію клієнтів через сайт компанії та 
--збереження їх основної інформації. Збереженої інформації повинно бути достатньо 
--для контактів та проведення поштових розсилок.
CREATE TABLE Client (
ID int CONSTRAINT PK_ClientID PRIMARY KEY NOT NULL IDENTITY(1, 1),
[Name] nvarchar(35) NOT NULL,
Surname nvarchar(35) NOT NULL,
[Date of bitrh] date NOT NULL,
[Registration date] date DEFAULT CONVERT(date, GETDATE()) NOT NULL);

CREATE TABLE Essence (
ID int CONSTRAINT PK_EssenceID PRIMARY KEY NOT NULL IDENTITY(1, 1),
[Type] nvarchar(30) NOT NULL);

INSERT INTO Essence ([Type])
VALUES ('Клієнт'), 
('Репетитор'), 
('Компанія');

CREATE TABLE [Contact type] (
ID int CONSTRAINT PK_ContactTypeID PRIMARY KEY NOT NULL IDENTITY(1, 1),
[Type] nvarchar(30) NOT NULL);

INSERT INTO [Contact type]
VALUES ('Моб. телефон'),
('Роб. телефон'),
('E-mail'),
('Skype'),
('Telegram'),
('Instagram');

CREATE TABLE [Contact book] (
ID int CONSTRAINT PK_ContactBookID PRIMARY KEY NOT NULL IDENTITY(1, 1),
[ID essence] int NOT NULL CONSTRAINT FK_Essense FOREIGN KEY REFERENCES Essence(ID), 
[ID in table] int NOT NULL, 
[ID contact type] int NOT NULL CONSTRAINT FK_ContactType FOREIGN KEY REFERENCES [Contact type](ID), 
Contact nvarchar(150) NOT NULL);
--ID essence (тип сутності: кліент, репетитор,...).
--ID in table (ID сутності в таблиці цієї сутності).
--ID contact type (тип контакту: моб. телефон, роб. тел., Skype,...).

--4.	Через сайт компанії може також зареєструватися репетитор, що надає освітні 
--послуги через посередника «LazyStudent». Репетитор має профільні дисципліни 
--(довільна кількість) та рейтинг, що визначається клієнтами, що з ним уже працювали. 
CREATE TABLE Coach (
ID int CONSTRAINT PK_CoachID PRIMARY KEY NOT NULL IDENTITY(1, 1),
[Name] nvarchar(35) NOT NULL,
Surname nvarchar(35) NOT NULL,
[Date of bitrh] date NOT NULL,
[Registration date] date DEFAULT CONVERT(date, GETDATE()) NOT NULL,
Education nvarchar(100) NOT NULL);
--[Date of bitrh] для того, щоб вітати з Днем Народження, адже у нас хороша компанія :)
--Education - відомості про здобуту освіту.

CREATE TABLE Subjects (
ID int CONSTRAINT PK_SubjectID PRIMARY KEY NOT NULL IDENTITY(1, 1),
[ID coach] int NOT NULL CONSTRAINT FK_CoachID FOREIGN KEY REFERENCES Coach(ID),
[Subject] nvarchar(100) NOT NULL,
Rating float DEFAULT 0 NOT NULL,
[Rating counter] int DEFAULT 0 NOT NULL,
[Student counter] int DEFAULT 0 NOT NULL);
--[Rating counter] - кількість клієнтів, по яким сформований рейтинг відносно
--цієї дисципліни.
--[Student counter] - кількість студентів, які "пройшли через руки репетитора"
--відносно цієї дисципліни.

--5.	Компанії, з якими співпрацює підприємство, також мають зберігатися в БД.
CREATE TABLE Company (
ID int CONSTRAINT PK_CompanyID PRIMARY KEY NOT NULL IDENTITY(1, 1),
[Name] nvarchar(100) NOT NULL,
Country nvarchar(50),
City nvarchar(50),
Street nvarchar(50),
[Registration date] date DEFAULT CONVERT(date, GETDATE()) NOT NULL);
--Country, City, Street можуть бути NULL, тому що це може бути інтернет-компанія, яка
--не має офісу.

--6.	Співробітники підприємства повинні мати можливість відстежувати замовлення 
--клієнтів та їх поточний статус. Передбачити можливість побудови звітності 
--(в тому числі і фінансової) в розрізі періоду, клієнту, репетитора/компанії.
CREATE TABLE Orders (
ID int CONSTRAINT PK_OrderID PRIMARY KEY NOT NULL IDENTITY(1, 1),
[ID client] int NOT NULL,
[ID essence] int NOT NULL CONSTRAINT FK_OrdersEssense FOREIGN KEY REFERENCES Essence(ID),
[ID in table] int NOT NULL,
[ID subject] int NOT NULL,
[Start date] date NOT NULL,
[Finish date] date NOT NULL,
[Order date] date DEFAULT CONVERT(date, GETDATE()) NOT NULL,
[Status] tinyint,
Rating tinyint,
Price float NOT NULL,
Discount tinyint NOT NULL);
--Rating - оцінка замовником замовлення (тобто, оцінка роботи репетитора).
--ID subject - дисципліна, яку викладає репетитор.
--ID essence (тип сутності: кліент, репетитор,...).
--ID in table (ID сутності в таблиці цієї сутності).
--Status - поточний статус замовлення.
--Discount = 0 or 1.

CREATE TABLE Discount (
ID int CONSTRAINT PK_DiscountID PRIMARY KEY NOT NULL IDENTITY(1, 1),
[Order ID] int NOT NULL CONSTRAINT FK_OrderID FOREIGN KEY REFERENCES Orders(ID),
Discount float NOT NULL);

CREATE OR ALTER PROCEDURE spGetOrdersCoach @DateFrom date = '0001-01-01', @DateTo date = '9999-12-31',
	@EssenseName nvarchar(35) = NULL, @EssenseSurname nvarchar(35) = NULL, 
	@Essence nvarchar(30) = 'Репетитор' AS
BEGIN
	SELECT * FROM Orders
		WHERE [Order date] BETWEEN @DateFrom AND @DateTo
		AND [ID essence] IN (SELECT ID FROM Essence WHERE [Type] = @Essence)
		AND [ID in table] IN (SELECT ID FROM Coach WHERE [Name] = @EssenseName 
			AND Surname = @EssenseSurname)
END

CREATE OR ALTER PROCEDURE spGetOrdersCompany @DateFrom date = '0001-01-01', @DateTo date = '9999-12-31',
	@CompanyName nvarchar(35) = NULL, @Essence nvarchar(30) = 'Компанія' AS
BEGIN
	SELECT * FROM Orders
		WHERE [Order date] BETWEEN @DateFrom AND @DateTo
		AND [ID essence] IN (SELECT ID FROM Essence WHERE [Type] = @Essence)
		AND [ID in table] IN (SELECT ID FROM Company WHERE [Name] = @CompanyName)
END

CREATE OR ALTER PROCEDURE spGetOrdersClient @DateFrom date = '0001-01-01', @DateTo date = '9999-12-31',
	@ClientName nvarchar(35) = NULL, @ClientSurname nvarchar(35) = NULL AS
BEGIN
	SELECT * FROM Orders
		WHERE [Order date] BETWEEN @DateFrom AND @DateTo
		AND [ID client] IN (SELECT ID FROM Client WHERE [Name] = @ClientName 
			AND Surname = @ClientSurname)
END

CREATE OR ALTER PROCEDURE spGetOrdersDate @DateFrom date = '0001-01-01', @DateTo date = '9999-12-31' AS
BEGIN
	SELECT * FROM Orders
		WHERE [Order date] BETWEEN @DateFrom AND @DateTo
END

CREATE OR ALTER PROCEDURE spGetOrders @DateFrom date = '0001-01-01', @DateTo date = '9999-12-31',
	@Essence nvarchar(30) = NULL, @ClientName nvarchar(35) = NULL, 
	@ClientSurname nvarchar(35) = NULL, @EssenseName nvarchar(35) = NULL,
	@EssenseSurname nvarchar(35) = NULL AS
BEGIN
	IF (@Essence = NULL AND @ClientName = NULL AND @ClientSurname = NULL
	AND @EssenseName = NULL AND @EssenseSurname = NULL)
		SELECT * FROM Orders
		WHERE [Order date] BETWEEN @DateFrom AND @DateTo
	IF (@Essence IS NOT NULL AND @ClientName = NULL AND @ClientSurname = NULL
	AND @EssenseName IS NOT NULL AND @EssenseSurname = NULL)
		SELECT * FROM Orders
		WHERE [Order date] BETWEEN @DateFrom AND @DateTo
		AND [ID essence] IN (SELECT ID FROM Essence WHERE [Type] = @Essence)
		AND [ID in table] IN (SELECT ID FROM Company WHERE [Name] = @EssenseName)
	IF (@Essence = NULL AND @ClientName IS NOT NULL AND @ClientSurname IS NOT NULL
	AND @EssenseName = NULL AND @EssenseSurname = NULL)
		SELECT * FROM Orders
		WHERE [Order date] BETWEEN @DateFrom AND @DateTo
		AND [ID client] IN (SELECT ID FROM Client WHERE [Name] = @ClientName 
			AND Surname = @ClientSurname)
	IF (@Essence IS NOT NULL AND @ClientName = NULL AND @ClientSurname = NULL
	AND @EssenseName IS NOT NULL AND @EssenseSurname IS NOT NULL)
		SELECT * FROM Orders
		WHERE [Order date] BETWEEN @DateFrom AND @DateTo
		AND [ID essence] IN (SELECT ID FROM Essence WHERE [Type] = @Essence)
		AND [ID in table] IN (SELECT ID FROM Coach WHERE [Name] = @EssenseName 
			AND Surname = @EssenseSurname)
END

--7.	Передбачити ролі адміністратора, рядового працівника та керівника. 
--Відповідним чином розподілити права доступу.
CREATE ROLE Administrator;

GRANT ALL ON DATABASE::LazyStudent TO Administrator;

CREATE ROLE Chief;

GRANT SELECT ON DATABASE::LazyStudent TO Chief;

CREATE ROLE Worker;

GRANT SELECT ON Client TO Worker;
GRANT SELECT ON Coach TO Worker;
GRANT SELECT ON Company TO Worker;
GRANT SELECT ON [Contact book] TO Worker;
GRANT SELECT ON Orders TO Worker;
GRANT SELECT ON Discount TO Worker;

--8.	Передбачити історію видалень інформації з БД. Відповідна інформація не повинна 
--відображатися на боці сайту, але керівник та адміністратор мусять мати можливість 
--переглянути хто, коли і яку інформацію видалив.
CREATE TABLE ClientArchive (
ID int NOT NULL,
[Name] nvarchar(35) NOT NULL,
Surname nvarchar(35) NOT NULL,
[Date of bitrh] date NOT NULL,
[Registration date] date NOT NULL,
[Deleted date] date NOT NULL,
[Deleted by] nvarchar(250) NOT NULL);

DENY ALL ON ClientArchive TO PUBLIC;
GRANT SELECT ON ClientArchive TO Administrator;
GRANT SELECT ON ClientArchive TO Chief;

CREATE TRIGGER trClientDelete ON Client
AFTER DELETE AS
BEGIN
	INSERT INTO ClientArchive (ID, [Name], Surname, [Date of bitrh], 
		[Registration date], [Deleted date], [Deleted by])
	SELECT ID, [Name], Surname, [Date of bitrh], [Registration date], CONVERT(date, GETDATE()),
		CURRENT_USER FROM deleted
END

CREATE TABLE EssenceArchive (
ID int NOT NULL,
[Type] nvarchar(30) NOT NULL,
[Deleted date] date NOT NULL,
[Deleted by] nvarchar(250) NOT NULL);

DENY ALL ON EssenceArchive TO PUBLIC;
GRANT SELECT ON EssenceArchive TO Administrator;
GRANT SELECT ON EssenceArchive TO Chief;

CREATE TRIGGER trEssenceDelete ON Essence
AFTER DELETE AS
BEGIN
	INSERT INTO EssenceArchive (ID, [Type], [Deleted date], [Deleted by])
	SELECT ID, [Type], CONVERT(date, GETDATE()), CURRENT_USER FROM deleted
END

CREATE TABLE [Contact type Archive] (
ID int NOT NULL,
[Type] nvarchar(30) NOT NULL,
[Deleted date] date NOT NULL,
[Deleted by] nvarchar(250) NOT NULL);

DENY ALL ON [Contact type Archive] TO PUBLIC;
GRANT SELECT ON [Contact type Archive] TO Administrator;
GRANT SELECT ON [Contact type Archive] TO Chief;

CREATE TRIGGER trContactTypeDelete ON [Contact type]
AFTER DELETE AS
BEGIN
	INSERT INTO [Contact type Archive] (ID, [Type], [Deleted date], [Deleted by])
	SELECT ID, [Type], CONVERT(date, GETDATE()), CURRENT_USER FROM deleted
END

CREATE TABLE [Contact book Archive] (
ID int NOT NULL,
[ID essence] int NOT NULL, 
[ID in table] int NOT NULL, 
[ID contact type] int NOT NULL, 
Contact nvarchar(150) NOT NULL,
[Deleted date] date NOT NULL,
[Deleted by] nvarchar(250) NOT NULL);

DENY ALL ON [Contact book Archive] TO PUBLIC;
GRANT SELECT ON [Contact book Archive] TO Administrator;
GRANT SELECT ON [Contact book Archive] TO Chief;

CREATE TRIGGER trContactBookDelete ON [Contact book]
AFTER DELETE AS
BEGIN
	INSERT INTO [Contact book Archive] (ID, [ID essence], [ID in table], [ID contact type],
		Contact, [Deleted date], [Deleted by])
	SELECT ID, [ID essence], [ID in table], [ID contact type], Contact, 
		CONVERT(date, GETDATE()), CURRENT_USER FROM deleted
END

CREATE TABLE CoachArchive (
ID int NOT NULL,
[Name] nvarchar(35) NOT NULL,
Surname nvarchar(35) NOT NULL,
[Date of bitrh] date NOT NULL,
[Registration date] date NOT NULL,
Education nvarchar(100) NOT NULL,
[Deleted date] date NOT NULL,
[Deleted by] nvarchar(250) NOT NULL);

DENY ALL ON CoachArchive TO PUBLIC;
GRANT SELECT ON CoachArchive TO Administrator;
GRANT SELECT ON CoachArchive TO Chief;

CREATE TRIGGER trCoachDelete ON Coach
AFTER DELETE AS
BEGIN
	INSERT INTO CoachArchive (ID, [Name], Surname, [Date of bitrh], [Registration date],
		Education, [Deleted date], [Deleted by])
	SELECT ID, [Name], Surname, [Date of bitrh], [Registration date],
		Education, CONVERT(date, GETDATE()), CURRENT_USER FROM deleted
END

CREATE TABLE SubjectsArchive (
ID int NOT NULL,
[ID coach] int NOT NULL,
[Subject] nvarchar(100) NOT NULL,
Rating float DEFAULT 0 NOT NULL,
[Rating counter] int NOT NULL,
[Student counter] int NOT NULL,
[Deleted date] date NOT NULL,
[Deleted by] nvarchar(250) NOT NULL);

DENY ALL ON SubjectsArchive TO PUBLIC;
GRANT SELECT ON SubjectsArchive TO Administrator;
GRANT SELECT ON SubjectsArchive TO Chief;

CREATE TRIGGER trSubjectsDelete ON Subjects
AFTER DELETE AS
BEGIN
	INSERT INTO SubjectsArchive (ID, [ID coach], [Subject], Rating, [Rating counter],
		[Student counter], [Deleted date], [Deleted by])
	SELECT ID, [ID coach], [Subject], Rating, [Rating counter],
		[Student counter], CONVERT(date, GETDATE()), CURRENT_USER FROM deleted
END

CREATE TABLE CompanyArchive (
ID int NOT NULL,
[Name] nvarchar(100) NOT NULL,
Country nvarchar(50),
City nvarchar(50),
Street nvarchar(50),
[Registration date] date NOT NULL,
[Deleted date] date NOT NULL,
[Deleted by] nvarchar(250) NOT NULL);

DENY ALL ON CompanyArchive TO PUBLIC;
GRANT SELECT ON CompanyArchive TO Administrator;
GRANT SELECT ON CompanyArchive TO Chief;

CREATE TRIGGER trCompanyDelete ON Company
AFTER DELETE AS
BEGIN
	INSERT INTO CompanyArchive (ID, [Name], Country, City, Street,
		[Registration date], [Deleted date], [Deleted by])
	SELECT ID, [Name], Country, City, Street,
		[Registration date], CONVERT(date, GETDATE()), CURRENT_USER FROM deleted
END

CREATE TABLE OrdersArchive (
ID int NOT NULL,
[ID client] int NOT NULL,
[ID essence] int NOT NULL,
[ID in table] int NOT NULL,
[ID subject] int NOT NULL,
[Start date] date NOT NULL,
[Finish date] date NOT NULL,
[Order date] date NOT NULL,
[Status] tinyint,
Rating tinyint,
Price float NOT NULL,
Discount tinyint NOT NULL,
[Deleted date] date NOT NULL,
[Deleted by] nvarchar(250) NOT NULL);

DENY ALL ON OrdersArchive TO PUBLIC;
GRANT SELECT ON OrdersArchive TO Administrator;
GRANT SELECT ON OrdersArchive TO Chief;

CREATE TRIGGER trOrdersDelete ON Orders
AFTER DELETE AS
BEGIN
	INSERT INTO OrdersArchive (ID, [ID client], [ID essence], [ID in table], [ID subject],
		[Start date], [Finish date], [Order date], [Status], Rating, Price, Discount,
		[Deleted date], [Deleted by])
	SELECT ID, [ID client], [ID essence], [ID in table], [ID subject],
		[Start date], [Finish date], [Order date], [Status], Rating, Price, Discount, 
		CONVERT(date, GETDATE()), CURRENT_USER FROM deleted
END

CREATE TABLE DiscountArchive (
ID int NOT NULL,
[Order ID] int NOT NULL,
Discount float NOT NULL,
[Deleted date] date NOT NULL,
[Deleted by] nvarchar(250) NOT NULL);

DENY ALL ON DiscountArchive TO PUBLIC;
GRANT SELECT ON DiscountArchive TO Administrator;
GRANT SELECT ON DiscountArchive TO Chief;

CREATE TRIGGER trDiscountDelete ON Discount
AFTER DELETE AS
BEGIN
	INSERT INTO DiscountArchive (ID, [Order ID], Discount, [Deleted date], [Deleted by])
	SELECT ID, [Order ID], Discount, CONVERT(date, GETDATE()), CURRENT_USER FROM deleted
END

--9.	Передбачити систему знижок в залежності від дати реєстрації клієнта. 1 рік – 5%, 
--2 роки – 8%, 3 роки – 11%, 4 роки – 15%. 
CREATE FUNCTION CountYears (@Date as date)
RETURNS int AS
BEGIN
RETURN (SELECT
CASE
	WHEN DATEFROMPARTS(1, DATEPART(month, GETDATE()), DATEPART(day, GETDATE())) < 
		DATEFROMPARTS(1, DATEPART(month, @Date), DATEPART(day, @Date))
		THEN DATEDIFF(year, @Date, GETDATE()) - 1
	ELSE DATEDIFF(year, @Date, GETDATE())
END AS Age)
END;

CREATE FUNCTION fnGetClientRegYears (@ClientID int)
RETURNS int
BEGIN
	DECLARE @regDate date;
	SET @regDate = (SELECT [Registration date] FROM Client WHERE ID = @ClientID)

	RETURN dbo.CountYears(@regDate)
END;

CREATE TRIGGER trGetDiscount ON Orders
AFTER INSERT AS
BEGIN
	INSERT INTO Discount ([Order ID], Discount)
	SELECT ID,
	CASE
		WHEN dbo.fnGetClientRegYears([ID client]) >= 4 THEN 15
		WHEN dbo.fnGetClientRegYears([ID client]) >= 3 THEN 11
		WHEN dbo.fnGetClientRegYears([ID client]) >= 2 THEN 8
		WHEN dbo.fnGetClientRegYears([ID client]) >= 1 THEN 5
		ELSE 0
	END
	 FROM inserted
END;

--10.	Передбачити можливість проведення акцій зі знижками на послуги компаній-партнерів 
--в залежності від компанії та дати проведення акції.
CREATE TABLE Stock (
ID int CONSTRAINT PK_ContactTypeID PRIMARY KEY NOT NULL IDENTITY(1, 1),
[ID company] int NOT NULL,
[Start date] date,
[Finish date] date,
Discount float NOT NULL);

CREATE TRIGGER trAddStockToDiscount ON Orders
AFTER INSERT AS
BEGIN
	DECLARE @ID_essence int;
	DECLARE @InsertedID_essence int;
	SET @ID_essence = (SELECT ID FROM Essence WHERE [Type] = 'Компанія');
	SET @InsertedID_essence = (SELECT [ID essence] FROM inserted);
	DECLARE @CompanyID int;
	SET @CompanyID = (SELECT [ID in table] FROM inserted);
	IF (@InsertedID_essence = @ID_essence AND
		@CompanyID IN (SELECT [ID company] FROM Stock) AND
		(GETDATE() BETWEEN (SELECT [Start date] FROM Stock WHERE [ID company] = @CompanyID) AND
		(SELECT [Finish date] FROM Stock WHERE [ID company] = @CompanyID)))
		INSERT INTO Discount ([Order ID], Discount)
		VALUES ((SELECT ID FROM inserted), (SELECT Discount FROM Stock WHERE [ID company] = @CompanyID))
END;
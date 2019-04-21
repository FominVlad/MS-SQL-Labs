--1.	Створити базу даних з ім’ям, що відповідає вашому прізвищу англійською мовою.
CREATE DATABASE Fomin;

--2.	Створити в новій базі таблицю Student з атрибутами StudentId, SecondName, 
--FirstName, Sex. Обрати для них оптимальний тип даних в вашій СУБД.
CREATE TABLE Student (
StudentID int NOT NULL,
SecondName nvarchar(30) NOT NULL,
FirstName nvarchar(30) NOT NULL,
Sex char(1) NOT NULL
);

--3.	Модифікувати таблицю Student. Атрибут StudentId має стати первинним ключем.
ALTER TABLE Student
ADD CONSTRAINT PK_StudentID PRIMARY KEY (StudentID);

--4.	Модифікувати таблицю Student. Атрибут StudentId повинен заповнюватися 
--автоматично починаючи з 1 і кроком в 1.
--
--Так как на данный момент у нас нету данных в базе - нужно удалить
--колонку StudentID и создать заново (как это сделано ниже),
--но уже с автоинкрементом.
ALTER TABLE Student
ADD StudentID int NOT NULL IDENTITY(1, 1) CONSTRAINT PK_StudentID PRIMARY KEY;

--5.	Модифікувати таблицю Student. Додати необов’язковий атрибут BirthDate за відповідним типом даних.
ALTER TABLE Student
ADD BirthDate date NULL;

--6.	Модифікувати таблицю Student. Додати атрибут CurrentAge, що генерується 
--автоматично на базі існуючих в таблиці даних.
CREATE FUNCTION CountAge (@Birthday as date)
RETURNS int AS
BEGIN
RETURN (SELECT
CASE
	WHEN DATEFROMPARTS(1, DATEPART(month, GETDATE()), DATEPART(day, GETDATE())) < 
		DATEFROMPARTS(1, DATEPART(month, @Birthday), DATEPART(day, @Birthday))
		THEN DATEDIFF(year, @Birthday, GETDATE()) - 1
	ELSE DATEDIFF(year, @Birthday, GETDATE())
END AS Age)
END;

ALTER TABLE Student
ADD CurrentAge AS dbo.CountAge(BirthDate);

--7.	Реалізувати перевірку вставлення даних. Значення атрибуту Sex може бути тільки ‘m’ та ‘f’.
ALTER TABLE Student
ADD CHECK (Sex IN ('m', 'f'));

--8.	В таблицю Student додати себе та двох «сусідів» у списку групи. 
INSERT INTO Student (SecondName, FirstName, Sex, BirthDate)
VALUES ('Fedorovich', 'Illya', 'm', '2000-05-08'),
('Fomin', 'Vladyslav', 'm', '1999-11-10'),
('Yukhta', 'Nikita', 'm', '1999-12-23');

--9.	Створити  представлення vMaleStudent та vFemaleStudent, що надають відповідну інформацію. 
CREATE VIEW vMaleStudent AS
SELECT * FROM Student
WHERE Student.Sex = 'm';

CREATE VIEW vFemaleStudent AS
SELECT * FROM Student
WHERE Student.Sex = 'f';

--10.	Змінити тип даних первинного ключа на TinyInt (або SmallInt) не втрачаючи дані.
ALTER TABLE Student
DROP CONSTRAINT PK_StudentID;

ALTER TABLE Student
ALTER COLUMN StudentID tinyint;

ALTER TABLE Student
ADD CONSTRAINT PK_StudentID PRIMARY KEY (StudentID);
--Проверяем, не потеряли ли мы данные:
SELECT * FROM Student

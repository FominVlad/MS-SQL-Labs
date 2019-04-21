--1.	�������� ���� ����� � ����, �� ������� ������ ������� ���������� �����.
CREATE DATABASE Fomin;

--2.	�������� � ���� ��� ������� Student � ���������� StudentId, SecondName, 
--FirstName, Sex. ������ ��� ��� ����������� ��� ����� � ����� ����.
CREATE TABLE Student (
StudentID int NOT NULL,
SecondName nvarchar(30) NOT NULL,
FirstName nvarchar(30) NOT NULL,
Sex char(1) NOT NULL
);

--3.	������������ ������� Student. ������� StudentId �� ����� ��������� ������.
ALTER TABLE Student
ADD CONSTRAINT PK_StudentID PRIMARY KEY (StudentID);

--4.	������������ ������� Student. ������� StudentId ������� ������������� 
--����������� ��������� � 1 � ������ � 1.
--
--��� ��� �� ������ ������ � ��� ���� ������ � ���� - ����� �������
--������� StudentID � ������� ������ (��� ��� ������� ����),
--�� ��� � ���������������.
ALTER TABLE Student
ADD StudentID int NOT NULL IDENTITY(1, 1) CONSTRAINT PK_StudentID PRIMARY KEY;

--5.	������������ ������� Student. ������ ������������� ������� BirthDate �� ��������� ����� �����.
ALTER TABLE Student
ADD BirthDate date NULL;

--6.	������������ ������� Student. ������ ������� CurrentAge, �� ���������� 
--����������� �� ��� �������� � ������� �����.
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

--7.	���������� �������� ���������� �����. �������� �������� Sex ���� ���� ����� �m� �� �f�.
ALTER TABLE Student
ADD CHECK (Sex IN ('m', 'f'));

--8.	� ������� Student ������ ���� �� ���� ������ � ������ �����. 
INSERT INTO Student (SecondName, FirstName, Sex, BirthDate)
VALUES ('Fedorovich', 'Illya', 'm', '2000-05-08'),
('Fomin', 'Vladyslav', 'm', '1999-11-10'),
('Yukhta', 'Nikita', 'm', '1999-12-23');

--9.	��������  ������������� vMaleStudent �� vFemaleStudent, �� ������� �������� ����������. 
CREATE VIEW vMaleStudent AS
SELECT * FROM Student
WHERE Student.Sex = 'm';

CREATE VIEW vFemaleStudent AS
SELECT * FROM Student
WHERE Student.Sex = 'f';

--10.	������ ��� ����� ���������� ����� �� TinyInt (��� SmallInt) �� ��������� ���.
ALTER TABLE Student
DROP CONSTRAINT PK_StudentID;

ALTER TABLE Student
ALTER COLUMN StudentID tinyint;

ALTER TABLE Student
ADD CONSTRAINT PK_StudentID PRIMARY KEY (StudentID);
--���������, �� �������� �� �� ������:
SELECT * FROM Student

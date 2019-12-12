--Practice--
CREATE TRIGGER MARKUP ON INGREDIENTS
AFTER UPDATE AS
UPDATE ITEMS 
SET PRICE=(SELECT 2*SUM(QUANTITY*UNITPRICE) FROM MADEWITH MW,INGREDIENT I
			WHERE MW.INGREDIENTID=I.INGREDIENTID AND ITEMS.ITEMID=MW.ITEMID);

CREATE VIEW NEW_EMP_DEPT
AS
SELECT E.EMPLOYEEID,FIRSTNAME,E.DEPTCODE,E.SALARY,D.NAME FROM EMPLOYEES E,DEPARTMENTS D
WHERE E.DEPTCODE=D.CODE;

SELECT * FROM NEW_EMP_DEPT;

CREATE TRIGGER NEW_EMP_DEPT_REMOVE ON NEW_EMP_DEPT
INSTEAD OF DELETE
AS
DELETE FROM EMPLOYEES
WHERE EMPLOYEEID IN (
SELECT EMPLOYEEID FROM DELETED);
DELETE FROM DEPARTMENTS
WHERE CODE IN (
SELECT DEPTCODE FROM DELETED);
GO

DROP TRIGGER NEW_EMP_DEPT_REMOVE;

--Exercise--
CREATE VIEW ALEX
AS
SELECT EMPLOYEEID,FIRSTNAME,LASTNAME,SALARY,CODE FROM EMPLOYEES INNER JOIN DEPARTMENTS ON EMPLOYEES.DEPTCODE=DEPARTMENTS.CODE;

SELECT * FROM ALEX;

--1
CREATE TRIGGER CONVERTTOUPPER ON EMPLOYEES
AFTER UPDATE,INSERT
AS
DECLARE EMP_CURSOR CURSOR
FOR SELECT FIRSTNAME,LASTNAME FROM INSERTED;

DECLARE 
	@FNAME VARCHAR(20),
	@LNAME VARCHAR(20);

OPEN EMP_CURSOR;

FETCH NEXT FROM EMP_CURSOR INTO @FNAME,@LNAME;
WHILE(@@FETCH_STATUS=0)
BEGIN
	UPDATE EMPLOYEES
	SET FIRSTNAME=UPPER(@FNAME),LASTNAME=UPPER(@LNAME)
	WHERE CURRENT OF EMP_CURSOR;

	FETCH NEXT FROM EMP_CURSOR INTO @FNAME,@LNAME;
END

CLOSE EMP_CURSOR;
DEALLOCATE EMP_CURSOR;

GO

--2
CREATE TRIGGER SALARY_CHECKER ON EMPLOYEES
INSTEAD OF UPDATE
AS
	BEGIN TRANSACTION TRANS;

	SAVE TRANSACTION CHECK_1;

	IF(EXISTS(SELECT * FROM INSERTED
				WHERE SALARY>100000))
		BEGIN RAISERROR('SALARY>100000 NOT ALLOWED',16,1);
		ROLLBACK TRANSACTION CHECK_1;
	END

	COMMIT TRANSACTION TRANS;
GO

--3
CREATE TRIGGER ALEX_INSERT ON ALEX
INSTEAD OF INSERT
AS
	BEGIN TRANSACTION TEMP;

	SAVE TRANSACTION P1;

	DECLARE
		@EMPLOYEEID NUMERIC(9),
		@FIRSTNAME VARCHAR(10),
		@LASTNAME VARCHAR(20),
		@CODE CHAR(5),
		@SALARY NUMERIC(9,2);

	SELECT @EMPLOYEEID=EMPLOYEEID,@FIRSTNAME=FIRSTNAME,@LASTNAME=LASTNAME,@CODE=CODE,@SALARY=SALARY FROM INSERTED;

	IF(@EMPLOYEEID IN (
	SELECT EMPLOYEEID FROM EMPLOYEES) OR
	@CODE NOT IN (
	SELECT CODE FROM DEPARTMENTS))
		ROLLBACK TRANSACTION P1;
	ELSE
		INSERT INTO EMPLOYEES
		VALUES(@EMPLOYEEID,@FIRSTNAME,@LASTNAME,@CODE,@SALARY);

	COMMIT TRANSACTION TEMP;
GO

--4
CREATE TRIGGER ALEX_DELETE ON ALEX
INSTEAD OF DELETE
AS
	BEGIN TRANSACTION TEMP;

	SAVE TRANSACTION T1;

	DECLARE
		@EMPLOYEEID NUMERIC(9),
		@FIRSTNAME VARCHAR(10),
		@LASTNAME VARCHAR(20),
		@CODE CHAR(5),
		@SALARY NUMERIC(9,2);

	DECLARE
		@INT_1 NUMERIC(9),
		@INT_2 NUMERIC(9);

	SELECT @INT_1 = COUNT(*) FROM (SELECT DISTINCT MANAGERID FROM DEPARTMENTS
									EXCEPT
									SELECT EMPLOYEEID FROM DELETED) D2;
	SELECT @INT_2 = COUNT(*) FROM (SELECT DISTINCT MANAGERID FROM DEPARTMENTS) D1;

	IF(@INT_2>@INT_1)
		ROLLBACK TRANSACTION T1;
	ELSE
	BEGIN
		DECLARE DELETE_CURSOR CURSOR
		FOR SELECT * FROM DELETED;

		OPEN DELETE_CURSOR;

		FETCH NEXT FROM DELETE_CURSOR INTO @EMPLOYEEID,@FIRSTNAME,@LASTNAME,@CODE,@SALARY;
		WHILE(@@FETCH_STATUS=0)
		BEGIN
			DELETE FROM WORKSON 
			WHERE EMPLOYEEID=@EMPLOYEEID;

			DELETE FROM EMPLOYEES
			WHERE EMPLOYEEID=@EMPLOYEEID;

			FETCH NEXT FROM DELETE_CURSOR INTO @EMPLOYEEID,@FIRSTNAME,@LASTNAME,@CODE,@SALARY;
		END

		CLOSE DELETE_CURSOR;
		DEALLOCATE DELETE_CURSOR;
	END

	COMMIT TRANSACTION TEMP;
GO

--5
CREATE TRIGGER ALEX_UPDATE ON ALEX
INSTEAD OF UPDATE
AS
	BEGIN TRANSACTION TEMP;

	SAVE TRANSACTION T1;

	DECLARE
		@INT1 NUMERIC(9),
		@INT2 NUMERIC(9),
		@INT3 NUMERIC(9);

	SELECT @INT1 = COUNT(DISTINCT EMPLOYEEID) FROM INSERTED;
	SELECT @INT2 = COUNT(*) FROM INSERTED;
	SELECT @INT3 = COUNT(*) FROM (
					SELECT * FROM INSERTED
					WHERE EMPLOYEEID IN 
					(SELECT EMPLOYEEID FROM EMPLOYEES)) D1;

	IF(@INT1!=@INT2 OR @INT3>0)
		ROLLBACK TRANSACTION T1;
	ELSE
	BEGIN
		DECLARE
			@INSERT_ID NUMERIC(9),
			@INSERT_CODE CHAR(5),
			@INSERT_FNAME VARCHAR(20),
			@INSERT_LNAME VARCHAR(20),
			@INSERT_SALARY NUMERIC(9,2);
			
		DECLARE
			@DELETE_ID NUMERIC(9),
			@DELETE_CODE CHAR(5),
			@DELETE_FNAME VARCHAR(20),
			@DELETE_LNAME VARCHAR(20),
			@DELETE_SALARY NUMERIC(9,2);

		DECLARE INSERT_CURSOR CURSOR
		FOR SELECT * FROM INSERTED;

		OPEN INSERT_CURSOR;

		FETCH NEXT FROM INSERT_CURSOR INTO @INSERT_ID,@INSERT_FNAME,@INSERT_LNAME,@INSERT_CODE,@INSERT_SALARY;

		DECLARE DELETE_CURSOR CURSOR
		FOR SELECT * FROM DELETED;

		OPEN DELETE_CURSOR;

		FETCH NEXT FROM DELETE_CURSOR INTO @DELETE_ID,@DELETE_FNAME,@DELETE_LNAME,@DELETE_CODE,@DELETE_SALARY;

		WHILE(@@FETCH_STATUS=0)
		BEGIN
			INSERT INTO EMPLOYEES
			VALUES(@INSERT_ID,@INSERT_FNAME,@INSERT_LNAME,@INSERT_CODE,@INSERT_SALARY);

			UPDATE WORKSON
			SET EMPLOYEEID=@INSERT_ID
			WHERE EMPLOYEEID=@DELETE_ID;

			UPDATE DEPARTMENTS
			SET MANAGERID=@INSERT_ID
			WHERE MANAGERID=@DELETE_ID;

			DELETE FROM EMPLOYEES
			WHERE EMPLOYEEID=@DELETE_ID;

			FETCH NEXT FROM INSERT_CURSOR INTO @INSERT_ID,@INSERT_FNAME,@INSERT_LNAME,@INSERT_CODE,@INSERT_SALARY;

			FETCH NEXT FROM DELETE_CURSOR INTO @DELETE_ID,@DELETE_FNAME,@DELETE_LNAME,@DELETE_CODE,@DELETE_SALARY;
		END

		CLOSE INSERT_CURSOR;
		DEALLOCATE INSERT_CURSOR;

		CLOSE DELETE_CURSOR;
		DEALLOCATE DELETE_CURSOR;
	END

	COMMIT TRANSACTION TEMP;
GO

--Practice--
SELECT EMPLOYEEID,FIRSTNAME,LASTNAME FROM EMPLOYEES
WHERE LASTNAME='ADVICE';

CREATE INDEX I_EMPLOYEES_LASTNAME ON EMPLOYEES(LASTNAME);

--unique index
CREATE UNIQUE INDEX I_EMPLOYEES_SALARY ON EMPLOYEES(SALARY);

--composite index
CREATE INDEX I_EMP_FNAME_LNAME ON EMPLOYEES(FIRSTNAME,LASTNAME);

--clustered
CREATE CLUSTERED INDEX IX_TEMP ON EMPLOYEES(LASTNAME ASC); --ERROR
--Cannot create more than one clustered index on table 'EMPLOYEES'. Drop the existing clustered index 'PK__employee__C135F5E9B3729424' before creating another.

--non-clustered
CREATE NONCLUSTERED INDEX IX_TEMP ON EMPLOYEES(LASTNAME ASC);

SELECT * FROM EMPLOYEES;

--function based index
SELECT FIRSTNAME,LASTNAME FROM EMPLOYEES
WHERE LASTNAME=UPPER('ADVICE');

ALTER TABLE dbo.employees ADD upper_firstname AS UPPER(firstname);
CREATE INDEX I_FUNC_EMP_LASTNAME ON EMPLOYEES(UPPER_FIRSTNAME);

--retrieving info on indexes
SELECT       
TableName = t.name,      
IndexName = ind.name, 
IndexId = ind.index_id,      
ColumnId = ic.index_column_id,      
ColumnName = col.name,      
ind.*,      
ic.*,      
col.*  
FROM sys.indexes ind INNER JOIN sys.index_columns ic ON ind.object_id = ic.object_id and ind.index_id = ic.index_id  INNER JOIN sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id  INNER JOIN sys.tables t ON ind.object_id = t.object_id  
ORDER BY t.name, ind.name, ind.index_id, ic.index_column_id; 
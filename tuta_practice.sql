-- Procedure create new staff
CREATE PROCEDURE createStaff(
	@name NVARCHAR(200),
	@gender NVARCHAR(200),
	@store_id INT
) AS
BEGIN
	-- Check if exist store
	SELECT id FROM sto.store WHERE id = @store_id;
	IF(@@ROWCOUNT = 0)
	THROW 51000, 'Store doesn''t exist!', 1

	-- Check if gender is valid
	IF @gender != 'male' AND @gender != 'female' AND @gender != 'unknown'
	THROW 51001, 'Gender is invalid! Gender must be either ''male'', ''female'' or ''unknown''', 1

	-- now insert new staff
	INSERT INTO sto.staff(staff_name, staff_gender, store_id)
	VALUES(@name, @gender, @store_id);
	PRINT('Insert staff successful!');
	SELECT SCOPE_IDENTITY() AS new_staff_id;
END;
GO

EXEC dbo.createStaff
	@name = 'Trung Nguyen',
	@gender = 'hehe',
	@store_id = 1;
GO

CREATE PROCEDURE getStaffInfoByStoreId(
	@store_id INT
) AS
BEGIN
	-- Check if exist store
	SELECT id FROM sto.store WHERE id = @store_id;
	IF(@@ROWCOUNT = 0)
	THROW 51000, 'Store doesn''t exist!', 1;

	DECLARE @staff_name NVARCHAR(200),
		@staff_gender NVARCHAR(200), @store_name NVARCHAR(200);

	DECLARE cursor_staff CURSOR
	FOR SELECT staff.staff_name, staff.staff_gender, store.store_name FROM sto.staff staff, sto.store store
		WHERE staff.store_id = store.id
		AND store.id = @store_id

	-- use cursor to traverse each record
	OPEN cursor_staff
	WHILE 1=1
		BEGIN
			FETCH NEXT FROM cursor_staff INTO
				@staff_name, @staff_gender, @store_name
			IF @@FETCH_STATUS != 0 BREAK;
			PRINT @staff_name + ' - ' + @staff_gender + ' - ' + @store_name;
		END;
	CLOSE cursor_staff;
	DEALLOCATE cursor_staff;
END;
GO

EXEC dbo.getStaffInfoByStoreId
	@store_id = 2;
GO

CREATE PROCEDURE updateStaff(
	@id INT,
	@name NVARCHAR(200),
	@gender NVARCHAR(200) = 'unknown',
	@store_id INT
) AS
BEGIN
	-- Check if exist staff
	SELECT id FROM sto.staff WHERE id = @id;
	IF(@@ROWCOUNT = 0)
	THROW 51002, 'Staff doesn''t exist!', 1;
	
	-- Check if exist store
	SELECT id FROM sto.store WHERE id = @store_id;
	IF(@@ROWCOUNT = 0)
	THROW 51000, 'Store doesn''t exist!', 1;

	-- Check if gender is valid
	IF @gender != 'male' AND @gender != 'female' AND @gender != 'unknown'
	THROW 51001, 'Gender is invalid! Gender must be either ''male'', ''female'' or ''unknown''', 1

	UPDATE sto.staff
	SET staff_name = @name, staff_gender = @gender, store_id = @store_id
	WHERE id = @id;
END;
GO

EXEC dbo.updateStaff
	@id = 1,
	@name = 'Demp Update',
	@gender = 'male',
	@store_id = 2;
GO


-- normal function
CREATE FUNCTION sumab(
	@a DEC(10,2),
	@B DEC(10,2)
) RETURNS DEC(20,2) AS
BEGIN
	RETURN @a + @b;
END;
GO

SELECT dbo.sumab(200, 100) AS sum;
GO

-- Table-valued Function: returns data of a table type
CREATE FUNCTION funcGetStaffInfoByStoreId(@store_id INT)
RETURNS TABLE AS
RETURN
	SELECT staff.staff_name, staff.staff_gender, store.store_name FROM sto.staff staff, sto.store store
		WHERE staff.store_id = store.id
		AND store.id = @store_id;
GO

SELECT * FROM dbo.funcGetStaffInfoByStoreId(1);
GO

-- Create a Multi-statement table-valued functions (MSTVF)
-- Contacts are the data of two tables: staff and customer
CREATE FUNCTION funcGetContacts()
RETURNS @contacts TABLE(
	name NVARCHAR(200),
	gender NVARCHAR(20),
	email NVARCHAR(200),
	phone NVARCHAR(50)
) AS
BEGIN
	INSERT INTO @contacts
	SELECT st.staff_name, st.staff_gender, st.staff_email, st.staff_phone FROM sto.staff st;
	
	INSERT INTO @contacts
	SELECT cus.cus_name, cus.cus_gender, cus.cus_email, cus.cus_phone FROM sto.customer cus;

	RETURN;
END;
GO

SELECT * FROM funcGetContacts();
GO


/**
Trigger:
- Triggers are special stored procedures that are executed automatically when a database event occur.
- 3 type of trigger:
  + DML triggers: are invoked automatically whenever an INSERT, UPDATE, DELETE event occur
  + DDL triggers: are invoked automatically whenever an CREATE, ALTER, DROP event occur
  + Logon triggers: which fire in response to LOGON events

**/
-- Create trigger after insert/delete staff
CREATE TRIGGER sto.trg_staff_ins_del
ON sto.staff
AFTER INSERT, DELETE AS
BEGIN
	-- suppress the number of rows affected messages from being returned whenever the trigger is fired.
	SET NOCOUNT ON;

	INSERT INTO sto.staff_log(staff_id, staff_name, staff_gender, staff_email, staff_phone, store_id, updated_at, operation)
	SELECT
		i.id,
		i.staff_name,
		i.staff_gender,
		i.staff_email,
		i.staff_phone,
		i.store_id,
		GETDATE(),
		'INS'
	FROM inserted i
	UNION ALL
	SELECT
		d.id,
		d.staff_name,
		d.staff_gender,
		d.staff_email,
		d.staff_phone,
		d.store_id,
		GETDATE(),
		'DEL'
	FROM deleted d
END;
GO

-- Create trigger after update staff
CREATE TRIGGER sto.trg_staff_upd
ON sto.staff
AFTER UPDATE AS
BEGIN
	-- suppress the number of rows affected messages from being returned whenever the trigger is fired.
	SET NOCOUNT ON;

	INSERT INTO sto.staff_log(
		staff_id,
		staff_name,
		staff_gender,
		staff_email,
		staff_phone,
		store_id,
		updated_at,
		operation)
	SELECT
		d.id,
		d.staff_name,
		d.staff_gender,
		d.staff_email,
		d.staff_phone,
		d.store_id,
		GETDATE(),
		'UPD'
	FROM deleted d
END;
GO

-- Test trigger
INSERT INTO sto.staff(
	staff_name,
	staff_gender,
	staff_email,
	staff_phone,
	store_id) VALUES
('Nguyen Bka', 'male', 'nguyen@gmail.com', '0899849294', 1);
GO

UPDATE sto.staff
SET staff_email = 'nguyenbka@gmail.com'
WHERE id = 1;
GO

DELETE sto.staff WHERE id = 1;
GO

-- INSTEAD OF trigger: is a trigger that skips a DML statement and execute other statements

----- DDL trigger
-- Suppose we want to capture all the modifications made to the database index
-- Create a DDL trigger to track index changes and insert events data into the index_logs table
CREATE TRIGGER trg_index_changes
ON DATABASE FOR CREATE_INDEX, ALTER_INDEX, DROP_INDEX AS
BEGIN
	SET NOCOUNT ON;

    INSERT INTO index_logs (
        event_data,
        changed_by
    )
    VALUES (
        EVENTDATA(),
        USER
    );
END;
GO

-- Now create index to test trigger
CREATE INDEX idx_staff_phone
ON sto.staff(staff_phone);
GO

CREATE INDEX idx_customer_phone
ON sto.customer(cus_phone);
GO

/** set operators:
- UNION: Select elements from both sets (remove duplicates). It is similar to FULL OUTER JOIN
- UNION ALL: Same as UNION operator (select elements from both sets), but contains duplicates
- INTERSECT: Select elements that are present in both sets. It is similar to INNER JOIN
- EXCEPT: A EXCEPT B will select all elements that are present in set A and NOT present in set B. It is similar to:
  A LEFT JOIN B ON A.key = B.key WHERE B.key IS NULL
**/
SELECT s.staff_gender
FROM sto.staff s
UNION
SELECT c.cus_gender
FROM sto.customer c;

SELECT s.staff_gender
FROM sto.staff s
UNION ALL
SELECT c.cus_gender
FROM sto.customer c;

SELECT s.staff_gender
FROM sto.staff s
INTERSECT
SELECT c.cus_gender
FROM sto.customer c;

SELECT s.staff_gender
FROM sto.staff s
EXCEPT
SELECT c.cus_gender
FROM sto.customer c;
CREATE DATABASE tuta;
GO
USE tuta;
GO

CREATE SCHEMA sto;	-- means 'store'
GO

CREATE TABLE sto.store(
	id INT IDENTITY PRIMARY KEY,
	store_name NVARCHAR(200),
	store_address NVARCHAR(200)
);
GO

CREATE TABLE sto.staff(
	id INT IDENTITY PRIMARY KEY,
	staff_name NVARCHAR(200),
	staff_gender NVARCHAR(20),
	store_id INT,
	CONSTRAINT fk_staff_store FOREIGN KEY (store_id) REFERENCES sto.store(id) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

INSERT INTO sto.store(store_name, store_address) VALUES('Tiki', '123 Nguyen Trai, Hanoi'), ('Shopee','456 Le Van Thiem, Hanoi');
GO
INSERT INTO sto.staff(staff_name, staff_gender, store_id)
VALUES('Nguyen Bka', 'male', '1'),
('Thanh Toan', 'male', '2'),
('Tu TA', 'male', '1'),
('Nhung Vu', 'female', '1'),
('Huy Tran', 'male', '2'),
('Khanh Linh', 'female', '1'),
('Huyen Nguyen', 'female', '2');
GO

CREATE TABLE sto.customer(
	id INT IDENTITY PRIMARY KEY,
	cus_name NVARCHAR(200),
	cus_gender NVARCHAR(20),
	cus_email NVARCHAR(200),
	cus_phone NVARCHAR(50),
);
GO

ALTER TABLE sto.staff
ADD staff_email NVARCHAR(200),
	staff_phone NVARCHAR(50);
GO

-- Add new data
UPDATE sto.staff SET staff_email = 'demo@gmail.com', staff_phone = '093234230' WHERE id = 1;
UPDATE sto.staff SET staff_email = 'toantv@gmail.com', staff_phone = '0873848423' WHERE id = 2;
UPDATE sto.staff SET staff_email = 'tuta@gmail.com', staff_phone = '0895935443' WHERE id = 3;
UPDATE sto.staff SET staff_email = 'nhung@gmail.com', staff_phone = '093234230' WHERE id = 4;
UPDATE sto.staff SET staff_email = 'huyt@gmail.com', staff_phone = '093234230' WHERE id = 5;
UPDATE sto.staff SET staff_email = 'kl@gmail.com', staff_phone = '093234230' WHERE id = 6;
UPDATE sto.staff SET staff_email = 'huyennguyen@gmail.com', staff_phone = '093234230' WHERE id = 7;
UPDATE sto.staff SET staff_email = 'trung@gmail.com', staff_phone = '093234230' WHERE id = 8;
UPDATE sto.staff SET staff_email = 'hoangha@gmail.com', staff_phone = '093234230' WHERE id = 9;
GO

INSERT INTO sto.customer(cus_name, cus_gender, cus_email, cus_phone) VALUES
('Tuzaku', 'male', 'tzk@yahoo.com', '08839489432'),
('att', 'female', 'att@yahoo.com', '08802842342'),
('Jame smith', 'male', 'jame@yahoo.com', '0895852432'),
('DonaldTrump', 'female', 'trump@yahoo.com', '0948753242'),
('Elon Musk', 'female', 'elon@yahoo.com', '0992425333'),
('Mark zuckerberg', 'male', 'mark@yahoo.com', '0104823423'),
('Bill Gates', 'male', 'bill@google.com', '095884254'),
('Anhtu', 'female', 'anhtu@google.com', '0947852342'),
('Tutaanh', 'female', 'tutaanh@yahoo.com', '0957438543'),
('Toanga', 'male', 'toanga@yahoo.com', '07584389543'),
('Diep Nguyen', 'unknown', 'diep@yahoo.com', '0893424732');
GO

INSERT INTO sto.staff(staff_name, staff_gender, store_id, staff_email, staff_phone) VALUES
('Diepnguyen', 'gay', '1', 'diep@gmail.com', '0874923842'),
('Hoanhathuynh', 'lesbian', '2', 'hoa@gmail.com', '087483242');
GO

-- This table is used by triggers in staff table
CREATE TABLE sto.staff_log (
	id INT IDENTITY PRIMARY KEY,
	staff_id INT,
	staff_name NVARCHAR(200),
	staff_gender NVARCHAR(20),
	staff_email NVARCHAR(200),
	staff_phone NVARCHAR(50),
	store_id INT,
    updated_at DATETIME NOT NULL,
    operation CHAR(3) NOT NULL,
    CHECK(operation = 'INS' or operation='UPD' or operation='DEL')
);
GO

-- This table is used by triggers in all table in database: whenever new trigger is created, a log will be saved in this table
CREATE TABLE index_logs (
    log_id INT IDENTITY PRIMARY KEY,
    event_data XML NOT NULL,
    changed_by SYSNAME NOT NULL
);
GO

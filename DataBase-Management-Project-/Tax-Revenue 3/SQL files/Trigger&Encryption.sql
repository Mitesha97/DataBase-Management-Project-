use Tax_revenue;

-------------------------Trigger for updating PAYMENT table------------------------------
CREATE TRIGGER tr_PAYMENT
on PAYMENT
AFTER  UPDATE
AS
BEGIN
	DECLARE @operation CHAR(6)
		SET @operation = CASE
		WHEN EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
					THEN 'Update'
				ELSE NULL
		END
 
	IF @operation = 'Update'
			INSERT INTO PAYMENT_LOGS ( TAX_CODE,Command, ChangeDate, PAY_AMT, PAY_DATE, PAY_MODE)
			SELECT i.TAX_CODE, @operation, GETDATE(),  i.PAY_AMT, i.PAY_DATE, d.PAY_MODE
			FROM deleted d, inserted i
END

-- Example 
UPDATE PAYMENT
SET PAY_AMT = 5005
WHERE TAX_CODE = 'T_CODE003';

SELECT * from PAYMENT_LOGS;



------------------------ TRIGGER for action on Registration Table ----------------------------

CREATE TRIGGER tr_userLogs 
on REGISTRATION
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @operation CHAR(6)
		SET @operation = CASE
				WHEN EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
					THEN 'Update'
				WHEN EXISTS(SELECT * FROM inserted)
					THEN 'Insert'
				WHEN EXISTS(SELECT * FROM deleted)
					THEN 'Delete'
				ELSE NULL
		END
	IF @operation = 'Delete'
			INSERT INTO USER_LOGS (USERID,Command, ChangeDate, PASSWD, EMAIL, TAX_PAYER_TYPE)
			SELECT d.USERID, @operation, GETDATE(),  d.PASSWD, d.EMAIL, d.TAX_PAYER_TYPE
			FROM deleted d
 
	IF @operation = 'Insert'
			INSERT INTO USER_LOGS (USERID,Command, ChangeDate, PASSWD, EMAIL, TAX_PAYER_TYPE)
			SELECT i.USERID, @operation, GETDATE(),  i.PASSWD, i.EMAIL, i.TAX_PAYER_TYPE
			FROM inserted i
 
	IF @operation = 'Update'
			INSERT INTO USER_LOGS (USERID,Command, ChangeDate, PASSWD, EMAIL, TAX_PAYER_TYPE)
			SELECT d.USERID, @operation, GETDATE(),  i.PASSWD, d.EMAIL, i.TAX_PAYER_TYPE
			FROM deleted d, inserted i
END

-- Example
INSERT INTO REGISTRATION (USERID, PASSWD,EMAIL, TAX_PAYER_TYPE) VALUES('0041', 'Roger Federer' , 'Roger.Federer@gmail.com', 'Corporate');
select * from USER_LOGS;
 DELETE FROM USER_LOGS;


DELETE FROM REGISTRATION
WHERE USERID = '0041';
select * from USER_LOGS;

UPDATE REGISTRATION
SET PASSWD = 'BLA BLA'
WHERE USERID = '0041';
select * from USER_LOGS;


-----------------------------------------------ENCRYPTION for PASSWORD--------------------------------------------------
GO
SELECT *
FROM sys.symmetric_keys
WHERE name = '##MS_ServiceMasterKey##';
GO

-- Create database Key
USE Tax_revenue;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Identification123';
GO

-- Create self signed certificate
USE Tax_revenue;
GO
CREATE CERTIFICATE Certificate1
WITH SUBJECT = 'Protect Data';
GO

-- Create symmetric Key
USE Tax_revenue;
GO
CREATE SYMMETRIC KEY SymmetricKey1 
 WITH ALGORITHM = AES_128 
 ENCRYPTION BY CERTIFICATE Certificate1;
GO

USE Tax_revenue;
GO
ALTER TABLE REGISTRATION  
ADD PASSWD_ENCRYPT varbinary(MAX) NULL
GO

-- Populating encrypted data into new column
USE Tax_revenue;
GO
-- Opens the symmetric key for use
OPEN SYMMETRIC KEY SymmetricKey1
DECRYPTION BY CERTIFICATE Certificate1;
GO


UPDATE REGISTRATION
SET PASSWD_ENCRYPT = EncryptByKey (Key_GUID('SymmetricKey1'),PASSWD)
FROM REGISTRATION ;
GO
-- Closes the symmetric key
CLOSE SYMMETRIC KEY SymmetricKey1;
GO




USE Tax_revenue;
GO
ALTER TABLE REGISTRATION
DROP COLUMN PASSWD;
GO


SELECT * FROM REGISTRATION 

--For Decryption ------------------------------------------------------------------
OPEN SYMMETRIC KEY SymmetricKey1
DECRYPTION BY CERTIFICATE Certificate1;
GO

SELECT PASSWD_ENCRYPT AS 'Encrypted data',
            CONVERT(varchar, DecryptByKey(PASSWD_ENCRYPT)) AS 'Decrypted PASSWORD'
            FROM REGISTRATION;
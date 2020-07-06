

-- PROCEDURE 1--

CREATE PROCEDURE AVG_SAL_BYAGE (@min int, @max int, @avg_sal int OUTPUT)
AS
BEGIN
SELECT @avg_sal = AVG(C.TOTAL_SAL)
FROM CITIZEN C WHERE AGE BETWEEN @min AND @max
END;
DECLARE @counts INT;
EXEC AVG_SAL_BYAGE @min  = 30, @max = 35,
@avg_sal = @counts OUTPUT;
SELECT @counts AS AVGSAL;

-----------------------------------------------------------------------------------------------------------

-- PROCEDURE 2 --
CREATE PROCEDURE TAX_HISTORY_CORPORATE(@EIN int) 
AS
SELECT C.EIN, C.USERID, C.TURNOVER, T.TAX_CODE, T.TAX_CATEGORY, P.PAY_AMT, D.R_AMT,D.R_TYPE
FROM CORPORATE C JOIN TAX T ON C.EIN = T.EIN
JOIN PAYMENT P ON T.TAX_CODE = P.TAX_CODE
JOIN DEDUCTION D ON C.EIN = D.EIN
WHERE C.EIN = @EIN;


EXEC TAX_HISTORY_CORPORATE @EIN = 035587529;

-----------------------------------------------------------------------------------------------------------

-- PROCEDURE 3 --
CREATE PROCEDURE TAX_HISTORY_CITIZEN(@SSN int) 
AS
SELECT C.SSN, C.USERID, C.FNAME,C.LNAME, C.TOTAL_SAL, T.TAX_CODE, T.TAX_CATEGORY, P.PAY_AMT, D.R_AMT,D.R_TYPE
FROM CITIZEN C JOIN TAX T ON C.SSN = T.SSN
JOIN PAYMENT P ON T.TAX_CODE = P.TAX_CODE
JOIN DEDUCTION D ON C.SSN = D.SSN
WHERE C.SSN = @SSN;

EXEC TAX_HISTORY_CITIZEN @SSN = 528580463;


-----------------------------------------------------------------------------------------------------------
--------------- PRODEURE 4 --------------------------------


CREATE PROCEDURE TAX_DETAIL(@SSN int)
AS
BEGIN
SELECT C.SSN, C.USERID, C.TOTAL_SAL, T.TAX_CODE, T.TAX_CATEGORY, P.PAY_AMT
FROM CITIZEN C JOIN TAX T ON C.SSN = T.SSN 
JOIN PAYMENT P ON T.TAX_CODE = P.TAX_CODE
WHERE C.SSN = @SSN
END;

EXEC TAX_DETAIL @SSN = 528580463;
--------------------------------------------------------------------

-- PROCEDURE 5--
CREATE PROCEDURE EXPTYPE_COST(@exptype VARCHAR (50))
AS 
SELECT E.EXP_TYPE , SUM(P.PAY_AMT) EXPENDITURE
FROM EXPENDITURE E JOIN PAYMENT P ON E.TAX_CODE = P.TAX_CODE
WHERE E.EXP_TYPE = @exptype
GROUP BY EXP_TYPE;

EXEC EXPTYPE_COST @exptype = 'Health';
-----------------------------------------------------------------------------------------------------------

-- VIEW 1  --
CREATE VIEW STATE_TOT_TAXCATEGORY AS
SELECT   G.STATE_ID,T.TAX_CATEGORY, SUM(P.PAY_AMT)TAX_RECEIVED
FROM TAX T JOIN PAYMENT P ON T.TAX_CODE = P.TAX_CODE
JOIN GOVERNMENT G ON G.TAX_CODE=T.TAX_CODE
GROUP BY G.STATE_ID,T.TAX_CATEGORY
ORDER BY G.STATE_ID OFFSET 0 ROW; 

SELECT * FROM STATE_TOT_TAXCATEGORY;


-----------------------------------------------------------------------------------------------------------


--- VIEW 2 --------------------

CREATE VIEW CIT_TAX_EXPENDITURE 
AS
SELECT  C.USERID, C.SSN, C.TOTAL_SAL, T.TAX_CODE, P.PAY_AMT, G.STATE_ID, TL.GOVT_TYPE, E.EXP_ID, E.EXP_TYPE
FROM CITIZEN C JOIN  TAX T ON C.SSN = T.SSN 
JOIN PAYMENT P ON P.TAX_CODE = T. TAX_CODE
JOIN GOVERNMENT G ON G.TAX_CODE = T.TAX_CODE
JOIN TAX_LEVEL TL ON TL.TAX_LEVEL = G. TAX_LEVEL
JOIN EXPENDITURE E ON E.TAX_CODE = G.TAX_CODE;

SELECT * FROM CIT_TAX_EXPENDITURE
-----------------------------------------------------------------------------------------------------------

-----VIEW 3 -----------------

CREATE VIEW STATE_EXP AS
SELECT EXP.EXP_TYPE , SUM(PAY.PAY_AMT) AS 'STATE' FROM 
((EXPENDITURE AS EXP INNER JOIN GOVERNMENT GOV ON EXP.TAX_CODE = GOV.TAX_CODE) INNER JOIN PAYMENT PAY ON GOV.TAX_CODE = PAY.TAX_CODE)
WHERE GOV.TAX_LEVEL = 'S' AND GOV.STATE_ID = 'MA' 
GROUP BY GOV.STATE_ID, EXP.EXP_TYPE;


CREATE VIEW FED_EXP AS
SELECT EXP.EXP_TYPE , SUM(PAY.PAY_AMT) AS 'FEDERAL' FROM 
((EXPENDITURE AS EXP INNER JOIN GOVERNMENT GOV ON EXP.TAX_CODE = GOV.TAX_CODE) INNER JOIN PAYMENT PAY ON GOV.TAX_CODE = PAY.TAX_CODE)
WHERE GOV.TAX_LEVEL = 'F' AND GOV.STATE_ID = 'MA' 
GROUP BY GOV.STATE_ID, EXP.EXP_TYPE;

CREATE VIEW EXPENDITURE_STATE_TYPE AS
SELECT STATE.EXP_TYPE, FED.FEDERAL , STATE.[STATE] FROM 
FED_EXP AS FED FULL OUTER JOIN STATE_EXP  STATE ON FED.EXP_TYPE = STATE.EXP_TYPE;

SELECT * FROM EXPENDITURE_STATE_TYPE;

---------------------------------------------------------------------------------------------------------- 






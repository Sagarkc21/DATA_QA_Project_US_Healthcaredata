------CREATED TABLE------

CREATE TABLE claims (
    claim_id INT,
    patient_id INT,
    provider_id INT,
    icd_code VARCHAR(10),
    cpt_code VARCHAR(10),
    service_date DATE,
    billing_amount FLOAT
);


--------iNSERTING DATA-------

WITH Numbers AS (
    SELECT TOP 500 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS gs
    FROM sys.objects
)
INSERT INTO claims (
    claim_id,
    patient_id,
    provider_id,
    icd_code,
    cpt_code,
    service_date,
    billing_amount
)
SELECT

    -- Duplicate claim IDs intentionally
    CASE 
        WHEN gs % 50 = 0 THEN 1
        ELSE gs
    END AS claim_id,

    -- NULL patient_id injection
    CASE 
        WHEN gs % 20 = 0 THEN NULL
        ELSE 1000 + gs % 100
    END AS patient_id,

    -- NULL provider_id injection
    CASE 
        WHEN gs % 25 = 0 THEN NULL
        ELSE 200 + gs % 50
    END AS provider_id,

    -- ✅ FIXED ICD-10 FORMAT (Letter + 2 digits + optional . + digits)
    CASE 
        WHEN gs % 15 = 0 THEN NULL
        WHEN gs % 10 = 0 THEN '12345'   -- invalid ICD
        ELSE 
            CHAR(65 + (gs % 26)) + 
            RIGHT('00' + CAST(gs % 90 AS VARCHAR(2)), 2) +
            CASE 
                WHEN gs % 3 = 0 
                THEN '.' + CAST(gs % 9 AS VARCHAR(1))
                ELSE ''
            END
    END AS icd_code,

    -- ✅ FIXED CPT FORMAT (ONLY 5 DIGITS)
    CASE 
        WHEN gs % 18 = 0 THEN NULL
        WHEN gs % 12 = 0 THEN 'ABCDE'   -- invalid CPT
        WHEN gs % 22 = 0 THEN '1234'    -- invalid CPT (4 digits)
        ELSE RIGHT('00000' + CAST(90000 + (gs % 1000) AS VARCHAR(5)), 5)
    END AS cpt_code,

    -- Service date with NULLs
    CASE 
        WHEN gs % 22 = 0 THEN NULL
        ELSE DATEADD(DAY, -(gs % 365), GETDATE())
    END AS service_date,

    -- Billing anomalies (negative, zero, normal)
    CASE 
        WHEN gs % 30 = 0 THEN -100.50
        WHEN gs % 40 = 0 THEN 0
        ELSE ROUND(RAND(CHECKSUM(NEWID())) * 1000, 2)
    END AS billing_amount

FROM Numbers;

------helps to removes data only from table.

truncate table claims;


-----CHECKING DATA----

SELECT * FROM claims;

---------------------------------------------------QA Workflow begins here--------------------------------------------
---Data Validation---

---ICDcode-----TC01


SELECT *
FROM claims
WHERE icd_code IS NULL

-- 1. must start with letter
OR icd_code NOT LIKE '[A-Z][0-9][0-9]%'

-- 2. invalid characters
OR PATINDEX('%[^A-Z0-9.]%', icd_code) > 0

-- 3. more than one dot (invalid)
OR (LEN(icd_code) - LEN(REPLACE(icd_code, '.', '')) > 1)

-- 4. dot cannot be last character
OR icd_code LIKE '%.'

-- 5. invalid structure: letter + digits must exist first
OR LEN(icd_code) < 3;


---CPTCODE----TC02

SELECT *
FROM claims
WHERE cpt_code IS NULL

   -- 1. must match allowed CPT structures
   OR (
        cpt_code NOT LIKE '[0-9][0-9][0-9][0-9][0-9]'   -- Category I
        AND cpt_code NOT LIKE '[0-9][0-9][0-9][0-9]F'    -- Category II
        AND cpt_code NOT LIKE '[0-9][0-9][0-9][0-9]T'    -- Category III
      )

   -- 2. invalid characters anywhere
   OR PATINDEX('%[^0-9FT]%', cpt_code) > 0

   -- 3. length must be 5 exactly (safe check)
   OR LEN(cpt_code) <> 5;



----Dublicate claims---TC03

SELECT 
    patient_id,
    service_date,
    cpt_code,
    icd_code,
    provider_id,
    billing_amount,
    COUNT(*) AS cnt
FROM claims
GROUP BY 
    patient_id,
    service_date,
    cpt_code,
    icd_code,
    provider_id,
    billing_amount
HAVING COUNT(*) > 1;


------Billing amount-----TC04--

SELECT *
FROM claims
WHERE billing_amount IS NULL
   OR billing_amount < 0;


------Service date Validation---TC05

SELECT *
FROM claims
WHERE service_date IS NULL
   OR service_date > GETDATE();

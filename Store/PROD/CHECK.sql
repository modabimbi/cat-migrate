--EXTERNAL_ID
SELECT count(*) 
FROM INVD_MAIN 
WHERE INVENTORY_TYPE_ID = 201 
AND LENGTH(EXTERNAL_ID) = 9 
and REGEXP_LIKE (EXTERNAL_ID, '\d{9}');
--4953623

select count(*) 
from INVUSER.INV_MASTER 
where INV_MASTER.EXTN_ID_TYPE = '201' 
and INV_MASTER.CREATED_BY = 'Migration';
 --4953623

SELECT
    COUNT(*)
FROM
    INVUSER.INV_MASTER
WHERE
    INV_MASTER.EXTN_ID_TYPE = '101'
    AND INV_MASTER.CREATED_BY = 'Migration';
--Total = 6687896 

SELECT
    COUNT(*)
FROM
    INVD_MAIN
WHERE INVENTORY_TYPE_ID = 101
AND EXTERNAL_ID NOT LIKE 'OLD%';
--6687896



--##########################################################################################################
 --1. ถ้าเป็นเบอร์ 201
--1.1 
SELECT count(*) 
FROM INVD_MAIN 
WHERE INVENTORY_TYPE_ID = 201 
and INVD_MAIN.PORTABILITY_INDICATOR = 1
AND LENGTH(EXTERNAL_ID) = 9 
and REGEXP_LIKE (EXTERNAL_ID, '\d{9}');
--Total = 1081871

select count(*) 
from INVUSER.INV_MASTER 
where EXTN_ID_TYPE = '201' 
and CREATED_BY = 'Migration'
and OPERATOR_ID = 1;
--1081871

--1.2 
SELECT count(*) 
FROM INVD_MAIN 
WHERE INVENTORY_TYPE_ID = 201 
and INVD_MAIN.PORTABILITY_INDICATOR = 0
AND LENGTH(EXTERNAL_ID) = 9 
and REGEXP_LIKE (EXTERNAL_ID, '\d{9}');
--Total = 3871752

select count(*) 
from INVUSER.INV_MASTER 
where EXTN_ID_TYPE = '201' 
and CREATED_BY = 'Migration'
and OPERATOR_ID = 0;
--3871752

--2. ถ้าเป็นซิม 101
select count(1) 
from INVUSER.INV_MASTER  m
join INVUSER.INV_MASTER_PROFILE p
on m.MASTER_ID = p.MASTER_ID
where m.EXTN_ID_TYPE = '101'
and m.CREATED_BY = 'Migration' 
and m.OPERATOR_ID = '1';
--Total = 6687896

SELECT count(1) 
FROM INVD_MAIN 
WHERE INVENTORY_TYPE_ID = 101 
and EXTERNAL_ID not like 'OLD%';
--6687896


--####################################################################################
--SALE_CHANEL 
--1. กรณีเป็นเบอร์ 201
SELECT M.SALES_CHANNEL_ID,COUNT(*) 
FROM INVD_MAIN m WHERE INVENTORY_TYPE_ID = 201 
AND LENGTH(EXTERNAL_ID) = 9
and REGEXP_LIKE (EXTERNAL_ID, '\d{9}')
GROUP BY M.SALES_CHANNEL_ID
order by to_number(M.SALES_CHANNEL_ID);

SELECT INV_SALE_CHANEL_MASTER.SALE_CHANEL_ID, COUNT(INV_SALE_CHANEL_MASTER.SALE_CHANEL_ID) 
FROM INVUSER.INV_MASTER JOIN INVUSER.INV_MASTER_PROFILE ON INV_MASTER.MASTER_ID = INV_MASTER_PROFILE.MASTER_ID 
JOIN INVUSER.INV_SALE_CHANEL_MASTER ON INV_MASTER_PROFILE.SALE_CHANEL = INV_SALE_CHANEL_MASTER.SALE_CHANEL_ID 
where INV_MASTER.EXTN_ID_TYPE = '201' and INV_MASTER.CREATED_BY = 'Migration'  GROUP BY INV_SALE_CHANEL_MASTER.SALE_CHANEL_ID
order by to_number( INV_SALE_CHANEL_MASTER.SALE_CHANEL_ID);

--2. กรณีเป็ยซิม 101
SELECT INV_SALE_CHANEL_MASTER.SALE_CHANEL_ID, COUNT(INV_SALE_CHANEL_MASTER.SALE_CHANEL_ID) 
FROM INVUSER.INV_MASTER JOIN INVUSER.INV_MASTER_PROFILE ON INV_MASTER.MASTER_ID = INV_MASTER_PROFILE.MASTER_ID 
JOIN INVUSER.INV_SALE_CHANEL_MASTER ON INV_MASTER_PROFILE.SALE_CHANEL = INV_SALE_CHANEL_MASTER.SALE_CHANEL_ID 
where INV_MASTER.EXTN_ID_TYPE = '101' and INV_MASTER.CREATED_BY = 'Migration' GROUP BY INV_SALE_CHANEL_MASTER.SALE_CHANEL_ID
--Total = 6687896
SELECT count(*) FROM INVD_MAIN WHERE INVENTORY_TYPE_ID = 101 AND REGEXP_LIKE (EXTERNAL_ID, '[[:digit:]]') and EXTERNAL_ID not like 'OLD%'
-- 6687896
--######################################################################################

--1. ถ้าเป็นเบอร์ 201
SELECT p.OWNER, COUNT(p.OWNER) 
FROM INVUSER.INV_MASTER m
JOIN INVUSER.INV_MASTER_PROFILE p
ON m.MASTER_ID = p.MASTER_ID 
where m.EXTN_ID_TYPE = '201' 
AND LENGTH(EXTERNAL_ID) = 9
AND REGEXP_LIKE (EXTERNAL_ID, '\d{9}')
AND m.CREATED_BY = 'Migration'
GROUP BY p.OWNER;

SELECT
    m.responsible_party_id,
    COUNT(*)
FROM
    invmig.invd_main m
WHERE
    inventory_type_id = 201
    AND length(external_id) = 9
    AND REGEXP_LIKE ( external_id,'\d{9}' )
GROUP BY
    m.responsible_party_id;


-- ยังไม่ผ่าน
--2. ถ้าเป็นซิม 101
SELECT INV_MASTER_PROFILE.OWNER, COUNT(1) 
FROM INVUSER.INV_MASTER INV_MASTER
JOIN INVUSER.INV_MASTER_PROFILE INV_MASTER_PROFILE 
ON INV_MASTER.MASTER_ID = INV_MASTER_PROFILE.MASTER_ID 
where INV_MASTER.EXTN_ID_TYPE = '101'
and INV_MASTER.CREATED_BY = 'Migration'
GROUP BY INV_MASTER_PROFILE.OWNER;

SELECT S.RESPONSIBLE_PARTY_ID,COUNT(*) 
FROM INVMIG.INVD_MAIN M 
LEFT JOIN INVMIG.ACCOUNT_SUBSCRIBER R ON M.EXTERNAL_ID = R.ADDTL_NOTIF_EXTERNAL_ID
LEFT JOIN INVMIG.INVD_MAIN S ON SUBSTR(R.RANGE_MAP_EXTERNAL_ID,3,9) = S.EXTERNAL_ID
WHERE M.INVENTORY_TYPE_ID = 101 AND REGEXP_LIKE (M.EXTERNAL_ID, '[[:digit:]]') and EXTERNAL_ID not like 'OLD%'
GROUP BY S.RESPONSIBLE_PARTY_ID;





--##########################################################################################

-- 1. เป็นเบอร์สวย Lucky = 1
select count(*) from INVUSER.INV_MASTER join INVUSER.INV_MASTER_PROFILE 
on INV_MASTER.MASTER_ID = INV_MASTER_PROFILE.MASTER_ID where INV_MASTER.EXTN_ID_TYPE = '201' 
and INV_MASTER.CREATED_BY = 'Migration' and INV_MASTER_PROFILE.LUCKY_NUMBER = '1';
--Total = 245789
SELECT COUNT(*)
FROM INVMIG.INVD_MAIN M 
WHERE M.INVENTORY_TYPE_ID = 201 
AND M.SALES_CHANNEL_ID IN (5,55)
AND REGEXP_LIKE (M.EXTERNAL_ID, '\d9')
AND LENGTH(EXTERNAL_ID) = 9  ;
--Total = 245789

2. ไม่เป็นเบอร์สวย Lucky = 0
select count(*) from INVUSER.INV_MASTER join INVUSER.INV_MASTER_PROFILE 
on INV_MASTER.MASTER_ID = INV_MASTER_PROFILE.MASTER_ID where INV_MASTER.EXTN_ID_TYPE = '201' 
and INV_MASTER.CREATED_BY = 'Migration' and INV_MASTER_PROFILE.LUCKY_NUMBER = '0';
--Total = 4707834
SELECT COUNT(*)
FROM INVMIG.INVD_MAIN M 
WHERE M.INVENTORY_TYPE_ID = 201 
AND ( M.SALES_CHANNEL_ID NOT IN (5,55) OR M.SALES_CHANNEL_ID IS NULL)
AND REGEXP_LIKE (M.EXTERNAL_ID, '\d{9}')
AND LENGTH(EXTERNAL_ID) = 9;
--Total = 4707834
-- ##
SELECT COUNT(*)
FROM INVMIG.INVD_MAIN M 
WHERE M.INVENTORY_TYPE_ID = 201 
AND ( M.SALES_CHANNEL_ID NOT IN (5,55) OR M.SALES_CHANNEL_ID IS NULL)
AND REGEXP_SUBSTR (EXTERNAL_ID, '\d{9}') is not null
AND LENGTH(EXTERNAL_ID) = 9;
--4707834


--3.กรณีเป็นซิม 101
select count(*) 
from INVUSER.INV_MASTER 
join INVUSER.INV_MASTER_PROFILE 
on INV_MASTER.MASTER_ID = INV_MASTER_PROFILE.MASTER_ID 
where INV_MASTER.EXTN_ID_TYPE = '101' 
and INV_MASTER.CREATED_BY = 'Migration' 
and INV_MASTER_PROFILE.LUCKY_NUMBER IS NULL;
-- Total = 6687896
SELECT COUNT(*)
FROM INVMIG.INVD_MAIN M 
WHERE M.INVENTORY_TYPE_ID = 101 
AND REGEXP_LIKE (M.EXTERNAL_ID, '[[:digit:]]')
AND EXTERNAL_ID NOT LIKE 'OLD%';
-- Total = 6687896


--###################################################################################################################################
-- 1. Prepaid (New INV)
select count(*) from INVUSER.INV_MASTER join INVUSER.INV_MASTER_PROFILE 
on INV_MASTER.MASTER_ID = INV_MASTER_PROFILE.MASTER_ID where INV_MASTER.EXTN_ID_TYPE = '201' 
and INV_MASTER.CREATED_BY = 'Migration' and INV_MASTER_PROFILE.PAYMENT_MODE = '0';
-- Total = 4214002
-- 2. Postpaid (New INV)
select count(*) from INVUSER.INV_MASTER join INVUSER.INV_MASTER_PROFILE 
on INV_MASTER.MASTER_ID = INV_MASTER_PROFILE.MASTER_ID where INV_MASTER.EXTN_ID_TYPE = '201' 
and INV_MASTER.CREATED_BY = 'Migration' and INV_MASTER_PROFILE.PAYMENT_MODE = '1';
-- Total = 739621
-- 3. Old INV
SELECT M.EQUIPMENT_CONDITION_ID, R.PAYMENT_MODE1,COUNT(*)
FROM INVMIG.INVD_MAIN M 
LEFT JOIN INVMIG.ACCOUNT_SUBSCRIBER R ON M.EXTERNAL_ID = SUBSTR(R.RANGE_MAP_EXTERNAL_ID,3,11)
WHERE M.INVENTORY_TYPE_ID = 201  AND REGEXP_LIKE (M.EXTERNAL_ID, '\d{9}')
AND LENGTH(EXTERNAL_ID) = 9  
GROUP BY M.EQUIPMENT_CONDITION_ID, R.PAYMENT_MODE1
-- Total = 


--############################################################################################

SQL for count records
SELECT COUNT(*) 
FROM INVMIG.ACCOUNT_SUBSCRIBER R
WHERE R.RANGE_MAP_EXTERNAL_ID IS NOT NULL and length(R.RANGE_MAP_EXTERNAL_ID) = 11

SQL check diff
SELECT * FROM INV_MAPPING M
LEFT JOIN INVMIG.ACCOUNT_SUBSCRIBER R ON M.EXTERNAL_ID = SUBSTR(R.RANGE_MAP_EXTERNAL_ID,3,11)
WHERE R.RANGE_MAP_EXTERNAL_ID IS NULL;

SQL check dup
SELECT EXTERNAL_ID,IMSI,SECONDARY_CODE,COUNT(*)  FROM INV_MAPPING I
GROUP BY EXTERNAL_ID,IMSI,SECONDARY_CODE HAVING COUNT(*) > 1

--##############################################################################################
status_code
-- 1. กรณีเป็นเบอร์ 201
SELECT
    inv_status_master.status_code,
    COUNT(inv_status_master.status_code)
FROM
    invuser.inv_master
    JOIN invuser.inv_master_profile ON inv_master.master_id = inv_master_profile.master_id
    JOIN invuser.inv_status_master ON inv_master_profile.status = inv_status_master.status_code
WHERE
    inv_master.extn_id_type = '201'
    AND inv_master.created_by = 'Migration'
GROUP BY
    inv_status_master.status_code
ORDER BY
    to_NUmber(inv_status_master.status_code) ASC

SELECT V.STATUS_ID,R.CURRENT_STATE,R.PAYMENT_MODE1 ,COUNT(*) 
FROM INVMIG.INVD_MAIN M 
JOIN INVMIG.INVD_VIEWS V ON  M.INVENTORY_ID = V.INVENTORY_ID AND V.END_DATE_TIME IS NULL
LEFT JOIN INVMIG.ACCOUNT_SUBSCRIBER R ON M.EXTERNAL_ID = SUBSTR(R.RANGE_MAP_EXTERNAL_ID,3,9)
WHERE M.INVENTORY_TYPE_ID = 201 AND REGEXP_LIKE (M.EXTERNAL_ID, '\d{9}')
AND LENGTH(EXTERNAL_ID) = 9
GROUP BY V.STATUS_ID,R.CURRENT_STATE, R.PAYMENT_MODE1
order by to_number(V.STATUS_ID) , to_number(R.CURRENT_STATE) ,to_number(R.PAYMENT_MODE1)
--Diff เบอร์ หลัง join view
select EXTERNAL_ID , count(1) from (SELECT M.EXTERNAL_ID , V.STATUS_ID,R.CURRENT_STATE,R.PAYMENT_MODE1 
FROM INVMIG.INVD_MAIN M 
JOIN INVMIG.INVD_VIEWS V ON  M.INVENTORY_ID = V.INVENTORY_ID AND V.END_DATE_TIME IS NULL
LEFT JOIN INVMIG.ACCOUNT_SUBSCRIBER R ON M.EXTERNAL_ID = SUBSTR(R.RANGE_MAP_EXTERNAL_ID,3,9)
WHERE M.INVENTORY_TYPE_ID = 201 AND REGEXP_LIKE (M.EXTERNAL_ID, '\d{9}')
AND LENGTH(EXTERNAL_ID) = 9)A 
group by EXTERNAL_ID;

-- 2. กรณีเป็นซิม 101
SELECT
    inv_status_master.status_code,
    COUNT(inv_status_master.status_code)
FROM
    invuser.inv_master
    JOIN invuser.inv_master_profile ON inv_master.master_id = inv_master_profile.master_id
    JOIN invuser.inv_status_master ON inv_master_profile.status = inv_status_master.status_code
WHERE
    inv_master.extn_id_type = '101'
    AND inv_master.created_by = 'Migration'
GROUP BY
    inv_status_master.status_code
ORDER BY
    to_number(inv_status_master.status_code) ASC

SELECT V.STATUS_ID,R.CURRENT_STATE,R.PAYMENT_MODE1 ,COUNT(*) 
FROM INVMIG.INVD_MAIN M 
JOIN INVMIG.INVD_VIEWS V ON  M.INVENTORY_ID = V.INVENTORY_ID AND V.END_DATE_TIME IS NULL
LEFT JOIN INVMIG.ACCOUNT_SUBSCRIBER R ON M.EXTERNAL_ID = R.ADDTL_NOTIF_EXTERNAL_ID
WHERE M.INVENTORY_TYPE_ID = 101 AND REGEXP_LIKE (M.EXTERNAL_ID, '[[:digit:]]') and m.EXTERNAL_ID NOT LIKE 'OLD%'
GROUP BY V.STATUS_ID,R.CURRENT_STATE, R.PAYMENT_MODE1

select A.EXTERNAL_ID , count(1) from (
SELECT M.EXTERNAL_ID ,V.STATUS_ID,R.CURRENT_STATE,R.PAYMENT_MODE1  
FROM INVMIG.INVD_MAIN M 
JOIN INVMIG.INVD_VIEWS V ON  M.INVENTORY_ID = V.INVENTORY_ID AND V.END_DATE_TIME IS NULL
LEFT JOIN INVMIG.ACCOUNT_SUBSCRIBER R ON M.EXTERNAL_ID = R.ADDTL_NOTIF_EXTERNAL_ID
WHERE M.INVENTORY_TYPE_ID = 101 AND REGEXP_LIKE (M.EXTERNAL_ID, '[[:digit:]]')
and m.EXTERNAL_ID NOT LIKE 'OLD%'
)A 
having count(1) > 1
group by A.EXTERNAL_ID
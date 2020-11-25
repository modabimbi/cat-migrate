create or replace PROCEDURE MIGRATE_INV_MASTER_2 AS 
 V_LIMITLOOP NUMBER:= 20000;
 V_ENDLOOP BOOLEAN := FALSE;



 V_COUNT_ALL_DATA NUMBER := 999999;


 CURSOR C_MAIN_DATA IS
  SELECT rowid,M.* FROM INVD_MAIN M 
  WHERE M.MIGRATE = 2
  AND M.INVENTORY_TYPE_ID <> '301'
  AND EXTERNAL_ID NOT LIKE 'OLD%'
  AND ROWNUM <= V_LIMITLOOP;

  V_INVENTORY_TYPE_ID varchar(3) := '';

  CURSOR C_INVD_VIEWS IS
     select * from INVD_VIEWS 
     where INVENTORY_ID = V_INVENTORY_TYPE_ID
     AND END_DATE_TIME IS NOT NULL
     order by START_DATE_TIME desc;


  MASTER_ID number(19,0) := 0;

  init_data INVUSER.INV_MASTER%ROWTYPE;
  init_data_profile INVUSER.INV_MASTER_PROFILE%ROWTYPE;

  V_COUNT_SIM number(3,0) := 0;
  V_COUNT_NEW number(16,0) := 0;
  V_DIFF number(16,0) := 0;
  PAYMENT_MODE1 VARCHAR2(20) := '';
  RANGE_MAP_EXTERNAL_ID VARCHAR2(30) := '';
  CURRENT_STATE  NUMBER(3,0) := 0;
  V_STATUS_ID NUMBER(10,0) := 0;
  V_VIEW_LOOP_INDEX number(5) := 0;
  V_COUNT_RTC NUMBER(5) := 0;
  V_COUNT_ASSIGNED NUMBER(5) := 0;
  V_COUNT_MV_NUMBER NUMBER(5) := 0;
  DAT C_MAIN_DATA%ROWTYPE;
BEGIN
--  SELECT COUNT(1) INTO V_COUNT_ALL_DATA 
--  FROM INVD_MAIN
--  where INVENTORY_TYPE_ID <> '301'
--  AND EXTERNAL_ID NOT LIKE 'OLD%';
  DBMS_OUTPUT.PUT_LINE( 'START MIGRATE_INV_MASTER_2 : ' || to_char(sysdate , 'dd/mm/yyyy hh24:mi'));
  WHILE V_ENDLOOP = FALSE
  LOOP
    BEGIN

--      SELECT COUNT(1) INTO V_COUNT_NEW 
--      FROM INVUSER.INV_MASTER;

--      IF V_COUNT_ALL_DATA - V_COUNT_NEW > 0 and V_DIFF <> V_COUNT_ALL_DATA - V_COUNT_NEW THEN
--         V_DIFF := V_COUNT_ALL_DATA - V_COUNT_NEW;
--         DBMS_OUTPUT.put_line(V_DIFF);
         OPEN C_MAIN_DATA;
--         DBMS_OUTPUT.PUT_LINE('C_MAIN_DATA : ' || C_MAIN_DATA%ROWCOUNT);
         LOOP
          FETCH C_MAIN_DATA INTO DAT;
          EXIT WHEN C_MAIN_DATA%NOTFOUND;


            begin
              init_data_profile := null;
              init_data := null;
              select INVUSER.INVMASTER_SEQ.nextval into MASTER_ID from dual;
              select INVUSER.INVMASTERPROFILE_SEQ.nextval into init_data_profile.MASTER_PROFILE_ID from dual;
              init_data_profile.STATUS := null;
              PAYMENT_MODE1 := null;
              CURRENT_STATE := null;
              V_COUNT_RTC := 0;

              V_INVENTORY_TYPE_ID := DAT.INVENTORY_TYPE_ID;
              V_VIEW_LOOP_INDEX := 1;
              FOR viewData in C_INVD_VIEWS
              LOOP
                IF V_VIEW_LOOP_INDEX = 1 THEN
                  init_data_profile.PREVIOUS_STATUS := viewData.STATUS_ID;
                ELSIF V_VIEW_LOOP_INDEX = 2 THEN
                  init_data_profile.STATUS_BEFORE_PREVIOUS := viewData.STATUS_ID;
                END IF;
                V_VIEW_LOOP_INDEX := V_VIEW_LOOP_INDEX+1;
              END LOOP;

              select STATUS_ID into V_STATUS_ID  from(
                  select STATUS_ID from INVD_VIEWS  
                  where INVENTORY_ID = DAT.INVENTORY_ID
                  AND END_DATE_TIME IS NULL
                  order by VIEW_ID desc
               )where rowNum <= 1;
              init_data.PIN1 := null;
              init_data.PIN2 := null;
              init_data.PUK1 := null;
              init_data.PUK2 := null;
              init_data.ZONE_ID := null;
              init_data.MVNO_ID := '999';
              init_data_profile.PAYMENT_MODE := null;
              Update INVD_MAIN m set m.MIGRATE = 9 where m.rowid = DAT.rowid;
              IF DAT.INVENTORY_TYPE_ID = '201' THEN
                SELECT count(1) into V_COUNT_RTC FROM ACCOUNT_SUBSCRIBER R WHERE RANGE_MAP_EXTERNAL_ID = '66'||DAT.EXTERNAL_ID;
                IF V_COUNT_RTC > 0 THEN
  --                DBMS_OUTPUT.PUT_LINE( 'err : ' || DAT.EXTERNAL_ID);
                  SELECT PAYMENT_MODE1 , CURRENT_STATE INTO PAYMENT_MODE1 , CURRENT_STATE 
                  from ( 
                    SELECT *  
                    FROM ACCOUNT_SUBSCRIBER R 
                    WHERE RANGE_MAP_EXTERNAL_ID = '66'||DAT.EXTERNAL_ID 
                    ORDER BY CREATION_DATE DESC
                  )
                  where rowNum <= 1;
                end if;
                IF REGEXP_SUBSTR (DAT.EXTERNAL_ID, '\d{9}') is null or  length(DAT.EXTERNAL_ID) <> 9 THEN 
                  CONTINUE; 
                end if;
                init_data.EXTERNAL_ID := DAT.EXTERNAL_ID;
                init_data.OPERATOR_ID := null;
                init_data.DIGIT := 2;
                init_data.IMSI := null;
                init_data.SECONDARY_CODE := null;
                init_data.SIM_CODE := null;
                init_data.SIM_FLAG := null;
                init_data.NUMBER_TYPE := 1;

                if DAT.PORTABILITY_INDICATOR = 1 then
                  init_data.OPERATOR_ID := 1;
                elsif DAT.PORTABILITY_INDICATOR = 0 then
                  init_data.OPERATOR_ID := 0;
                end if;


                init_data_profile.FLAG_VIP := 0;

                IF PAYMENT_MODE1 = '1' THEN 
                  init_data_profile.PAYMENT_MODE := 0;
                ELSIF PAYMENT_MODE1 = '2' THEN
                  init_data_profile.PAYMENT_MODE := 1;
                ELSE
                  IF DAT.EQUIPMENT_CONDITION_ID = 4 then
                    init_data_profile.PAYMENT_MODE := 1;
                  elsif DAT.EQUIPMENT_CONDITION_ID = 5 then
                    init_data_profile.PAYMENT_MODE := 0;
                  elsif DAT.EQUIPMENT_CONDITION_ID = 6 then
                    init_data_profile.PAYMENT_MODE := 1;
                  else
                     init_data_profile.PAYMENT_MODE := 0;
                  END IF;

                END IF;

                -- init_data_profile.LUCKY_NUMBER_LEVEL := DAT.PROFILE_ID;
                IF DAT.SALES_CHANNEL_ID is null THEN
                  init_data_profile.SALE_CHANEL := 7;

                else 
                  if DAT.SALES_CHANNEL_ID = 1 then
                     init_data_profile.SALE_CHANEL := 7;
                  -- 20201112
                  else
                      init_data_profile.SALE_CHANEL := DAT.SALES_CHANNEL_ID;
                   end if;
                END IF;

                IF DAT.SALES_CHANNEL_ID = '5' or DAT.SALES_CHANNEL_ID = '55' THEN
                  init_data_profile.LUCKY_NUMBER := 1;
                  init_data_profile.LUCKY_NUMBER_LEVEL := 100;
                  ELSE
                   init_data_profile.LUCKY_NUMBER := 0;
                   init_data_profile.LUCKY_NUMBER_LEVEL := 0;
                END IF;



                IF DAT.RESPONSIBLE_PARTY_ID is null THEN
                  init_data_profile.OWNER := 2;
                 else
                  init_data_profile.OWNER := DAT.RESPONSIBLE_PARTY_ID;

                END IF;
                IF DAT.SALES_CHANNEL_ID = 8 THEN
                  init_data_profile.NON_CHARGE := 0;
                else
                  init_data_profile.NON_CHARGE := 1;
                END IF;

                
                IF (V_STATUS_ID = 1 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 52 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 7 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 52 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 53 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 53 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 52 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 7 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 53 AND PAYMENT_MODE1 is null )
                  or (V_STATUS_ID = 4 AND CURRENT_STATE = 52 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 4 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE = 7 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 13 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 13 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 13 AND CURRENT_STATE = 52 AND PAYMENT_MODE1 = 2 )
                then
                  init_data_profile.STATUS := 2;
                elsif (V_STATUS_ID = 4 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null ) then 
                  init_data_profile.STATUS := 4;
                elsif (V_STATUS_ID = 1 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null )
                then
                  init_data_profile.STATUS := 1;
                elsif (V_STATUS_ID = 3 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null ) then
                  init_data_profile.STATUS := 3;
                elsif (V_STATUS_ID = 10 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null ) then
                  init_data_profile.STATUS := 10;
                elsif (V_STATUS_ID = 7 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 7 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null )
                  or (V_STATUS_ID = 7 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 2 )
                then 
                  init_data_profile.STATUS := 7;
                elsif (V_STATUS_ID = 1 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 3 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 3 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 3 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 4 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE = 3 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 11 AND CURRENT_STATE = 3 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 13 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 13 AND CURRENT_STATE = 3 AND PAYMENT_MODE1 = 1 )
                then 
                  init_data_profile.STATUS := 16;
                elsif (V_STATUS_ID = 15 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null ) then
                  init_data_profile.STATUS := 15;
                elsif (V_STATUS_ID = 11 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null )
                or (V_STATUS_ID = 11 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 1 )
                then
                  init_data_profile.STATUS := 11;
                elsif (V_STATUS_ID = 13 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null ) then
                  init_data_profile.STATUS := 13;
                elsif (V_STATUS_ID = 12 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null ) then
                  init_data_profile.STATUS := 12;
                else
                  init_data_profile.STATUS := 2;
                end if;


                


                select count(1) into V_COUNT_ASSIGNED from MVNO_ASSIGNED_NUMBER where TN = '0'||DAT.EXTERNAL_ID;
                IF V_COUNT_ASSIGNED > 0 THEN
                  select ID INTO init_data.MVNO_ID from (
                    select MM.ID 
                    from MVNO_ASSIGNED_NUMBER MA, MVNO_MASTER MM
                    where MA.MVNO_NAME = MM.NAME
                    AND TN = '0'||DAT.EXTERNAL_ID
                    order by MODIFIED_DATE DESC
                  )WHERE ROWNUM <= 1;
                ELSE
                  BEGIN
                    SELECT COUNT(1) INTO V_COUNT_MV_NUMBER FROM MVNO_NUMBER_RANGE MN
                    WHERE  MN.RANGE_START_NO <= DAT.EXTERNAL_ID
                    AND MN.RANGE_END_NO >= DAT.EXTERNAL_ID;
                  EXCEPTION   
                    WHEN others THEN 
                     V_COUNT_MV_NUMBER := 0;
                  END;

                  IF V_COUNT_MV_NUMBER > 0 THEN

                    SELECT ID INTO init_data.MVNO_ID FROM (
                      SELECT ID  FROM MVNO_NUMBER_RANGE MN, MVNO_MASTER MM
                      WHERE MN.OPERATOR_CODE = MM.NAME
                      AND MN.RANGE_START_NO <= DAT.EXTERNAL_ID
                    AND MN.RANGE_END_NO >= DAT.EXTERNAL_ID
                      ORDER BY ACTIVE_DATE DESC
                    )WHERE ROWNUM <= 1;

                  ELSE
                   BEGIN
                      SELECT ID INTO init_data.MVNO_ID FROM (
                        SELECT ID FROM MNP_NUMBERING_CLH MC , MVNO_MASTER MM
                        WHERE MC.OPER = MM.NAME
                        AND MC.PREFIX = SUBSTR('0'||DAT.EXTERNAL_ID , 1 , 6)
                        ORDER BY MC.DOCUMENT_DATE
                      )WHERE ROWNUM <= 1;
                        EXCEPTION   
                      WHEN others THEN 
                       V_COUNT_MV_NUMBER := 0;
                  END;
                  END IF;

                END IF;



             ELSIF DAT.INVENTORY_TYPE_ID = '101'  THEN

                SELECT count(1) into V_COUNT_RTC FROM ACCOUNT_SUBSCRIBER R WHERE ADDTL_NOTIF_EXTERNAL_ID = DAT.EXTERNAL_ID;
                IF V_COUNT_RTC > 0 THEN
  --                DBMS_OUTPUT.PUT_LINE( 'err : ' || DAT.EXTERNAL_ID);
                  SELECT PAYMENT_MODE1 , CURRENT_STATE , RANGE_MAP_EXTERNAL_ID INTO PAYMENT_MODE1 , CURRENT_STATE , RANGE_MAP_EXTERNAL_ID
                  from ( 
                    SELECT *  
                    FROM ACCOUNT_SUBSCRIBER R 
                    WHERE ADDTL_NOTIF_EXTERNAL_ID = DAT.EXTERNAL_ID  
                    ORDER BY CREATION_DATE DESC
                  )
                  where rowNum <= 1;


                end if;

                -- IF SUBSTR(DAT.EXTERNAL_ID , 0 , 2 ) <> '52' then
                --   CONTINUE; 
                -- END IF;
                init_data.EXTERNAL_ID := NULL;
                init_data.OPERATOR_ID := 1;
                init_data.DIGIT := null;
                init_data.IMSI := DAT.EXTERNAL_ID;
                init_data.SECONDARY_CODE := DAT.SECONDARY_CODE;
                init_data.SIM_CODE := null;   
                init_data.SIM_FLAG := 0;
                init_data.NUMBER_TYPE := null;
                init_data_profile.LUCKY_NUMBER := null;
                init_data_profile.LUCKY_NUMBER_LEVEL := null;
                select count(1) into V_COUNT_SIM from INVD_SIM_DETAIL s
                where s.IMSI = DAT.EXTERNAL_ID
                and s.ICCID = DAT.SECONDARY_CODE;

                if V_COUNT_SIM > 0 then
                  select s.PIN1 , s.PIN2 , s.PUK1 , s.PUK2 into init_data.PIN1 ,init_data.PIN2 ,init_data.PUK1 ,init_data.PUK2 from INVD_SIM_DETAIL s
                  where s.IMSI = DAT.EXTERNAL_ID
                  and s.ICCID = DAT.SECONDARY_CODE
                  and rowNum <= 1;
                end if;

                init_data_profile.FLAG_VIP := null;
                init_data_profile.SALE_CHANEL := 14;
                init_data_profile.NON_CHARGE := null;
                init_data_profile.PAYMENT_MODE := NULL;


                IF V_COUNT_RTC > 0 then
                --  DBMS_OUTPUT.PUT_LINE( 'err : ' || DAT.EXTERNAL_ID);
                  if RANGE_MAP_EXTERNAL_ID is not null then
                      select RESPONSIBLE_PARTY_ID into init_data_profile.OWNER from INVD_MAIN 
                        where EXTERNAL_ID = SUBSTR(RANGE_MAP_EXTERNAL_ID,3,9)
                        and rownum <= 1;
                  else 
                      init_data_profile.OWNER := 2;
                  end if;
                 
                else
                  init_data_profile.OWNER := 2;
                END IF;

                
                IF (V_STATUS_ID = 1 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 52 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 7 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 52 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 3 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 53 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 52 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 7 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 2 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 4 AND CURRENT_STATE = 52 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 4 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 4 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 4 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 5 AND CURRENT_STATE = 7 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 5 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 5 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 5 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 5 AND CURRENT_STATE = 52 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 5 AND CURRENT_STATE = 52 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 5 AND CURRENT_STATE = 53 AND PAYMENT_MODE1 is null )
                  or (V_STATUS_ID = 5 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 5 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 5 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 5 AND CURRENT_STATE = 53 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE = 52 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE = 7 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 9 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 9 AND CURRENT_STATE = 7 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 9 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 9 AND CURRENT_STATE = 51 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 9 AND CURRENT_STATE = 2 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 9 AND CURRENT_STATE = 53 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 9 AND CURRENT_STATE = 52 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 9 AND CURRENT_STATE = 50 AND PAYMENT_MODE1 = 1 )
                THEN
                  init_data_profile.STATUS := 2;
                ELSIF (V_STATUS_ID = 1 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null )
                THEN
                  init_data_profile.STATUS := 1;
                ELSIF (V_STATUS_ID = 2 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null )
                  or (V_STATUS_ID = 4 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null )
                  or (V_STATUS_ID = 5 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null )
                THEN
                  init_data_profile.STATUS := 5;
                ELSIF (V_STATUS_ID = 1 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 1 AND CURRENT_STATE = 3 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 5 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 2 )
                  or (V_STATUS_ID = 5 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE = 3 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 8 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 1 )
                  or (V_STATUS_ID = 9 AND CURRENT_STATE = 1 AND PAYMENT_MODE1 = 1 )
                THEN
                  init_data_profile.STATUS := 16;
                ELSIF (V_STATUS_ID = 9 AND CURRENT_STATE is null AND PAYMENT_MODE1 is null )
                THEN
                  init_data_profile.STATUS := 9;
                else 
                  init_data_profile.STATUS := 2;
                END IF;
                

              END IF;
  --            DBMS_OUTPUT.PUT_LINE( 'EXTERNAL_ID:' || DAT.EXTERNAL_ID || ',SECONDARY_CODE' || DAT.SECONDARY_CODE);

              -- IF V_STATUS_ID = 14 THEN
              --   init_data_profile.STATUS := 4;
              -- ELSIF V_STATUS_ID <> 8 AND V_STATUS_ID <> 14 THEN
              -- init_data_profile.STATUS := V_STATUS_ID;
              -- END IF;

              init_data.MASTER_ID := MASTER_ID;
              init_data.CREATED_DATE := SYSDATE;
              init_data.UPDATED_DATE := NULL;
              init_data.CREATED_BY := 'Migration';
              init_data.UPDATED_BY := NULL;
              init_data.IS_ACTIVE := 'Y';
              init_data.REMARK := null;


              init_data_profile.CREATED_DATE := SYSDATE;
              init_data_profile.UPDATED_DATE := NULL;
              init_data_profile.CREATED_BY := 'Migration';
              init_data_profile.UPDATED_BY := NULL;
              init_data_profile.IS_ACTIVE := 'Y';
              init_data_profile.REMARK := NULL;

              init_data_profile.MASTER_ID := MASTER_ID;
              init_data_profile.OM_OWNER := NULL;
              init_data_profile.OM_RESERVED_TYPE := NULL;
              init_data_profile.OM_RESERVED_DATE := NULL;
              init_data_profile.IS_TER_OCS := NULL;

              IF CURRENT_STATE = 2 THEN
                init_data_profile.IS_TER_OCS := 'N';
              ELSIF  CURRENT_STATE = 53 THEN
                init_data_profile.IS_TER_OCS := 'Y';
              END IF;



              if DAT.GEOGRAPHIC_REGION_ID = 7 then
                init_data.ZONE_ID := 1;
              elsif DAT.GEOGRAPHIC_REGION_ID = 3 then
                init_data.ZONE_ID := 2;
              elsif DAT.GEOGRAPHIC_REGION_ID = 4 then
                init_data.ZONE_ID := 3;
              elsif DAT.GEOGRAPHIC_REGION_ID = 1 then
                init_data.ZONE_ID := 4;
              elsif DAT.GEOGRAPHIC_REGION_ID = 2 then
                init_data.ZONE_ID := 5;
              elsif DAT.GEOGRAPHIC_REGION_ID = 5 then
                init_data.ZONE_ID := 6;
              elsif DAT.GEOGRAPHIC_REGION_ID = 6 then
                init_data.ZONE_ID := 7;
              else
                init_data.ZONE_ID := 1;
              end if;

              init_data.EXTN_ID_TYPE := DAT.INVENTORY_TYPE_ID;

              --  if init_data_profile.PAYMENT_MODE = 1 and init_data_profile.STATUS = 8 then --FIX 8 ==> 1 2020/11/06
              --   init_data_profile.STATUS := 1; 
              -- end if;
              if (CURRENT_STATE = 1 AND PAYMENT_MODE1 = 1 ) then
                    init_data_profile.STATUS := 16;
              end if;
              if (CURRENT_STATE = 2 OR CURRENT_STATE = 7 OR CURRENT_STATE = 50 OR CURRENT_STATE = 51 OR CURRENT_STATE = 52 OR CURRENT_STATE = 53) then
                    init_data_profile.STATUS := 2;
              end if;

              INSERT INTO INVUSER.INV_MASTER 
              ( MASTER_ID, CREATED_DATE, UPDATED_DATE, CREATED_BY, UPDATED_BY, IS_ACTIVE, REMARK, EXTERNAL_ID, EXTN_ID_TYPE, MVNO_ID, OPERATOR_ID, PIN1, PIN2, PUK1, PUK2, SECONDARY_CODE, ZONE_ID, IMSI, NUMBER_TYPE, SIM_FLAG, SIM_CODE, DIGIT ) 
              VALUES 
              ( init_data.MASTER_ID, init_data.CREATED_DATE, init_data.UPDATED_DATE, init_data.CREATED_BY, init_data.UPDATED_BY, init_data.IS_ACTIVE, init_data.REMARK, init_data.EXTERNAL_ID, init_data.EXTN_ID_TYPE, init_data.MVNO_ID, init_data.OPERATOR_ID, init_data.PIN1, init_data.PIN2, init_data.PUK1, init_data.PUK2, init_data.SECONDARY_CODE, init_data.ZONE_ID, init_data.IMSI, init_data.NUMBER_TYPE, init_data.SIM_FLAG, init_data.SIM_CODE, init_data.DIGIT );

              INSERT INTO INVUSER.INV_MASTER_PROFILE  
              (  MASTER_PROFILE_ID,  CREATED_DATE,  UPDATED_DATE,  CREATED_BY,  UPDATED_BY,  IS_ACTIVE,  REMARK,  LUCKY_NUMBER,  LUCKY_NUMBER_LEVEL,  NON_CHARGE,  OWNER,  PAYMENT_MODE,  SALE_CHANEL,  STATUS,  MASTER_ID,  FLAG_VIP,  PREVIOUS_STATUS,  STATUS_BEFORE_PREVIOUS,  OM_OWNER,  OM_RESERVED_TYPE,  OM_RESERVED_DATE,  IS_TER_OCS  )  
              VALUES  
              (  init_data_profile.MASTER_PROFILE_ID,  init_data_profile.CREATED_DATE,  init_data_profile.UPDATED_DATE,  init_data_profile.CREATED_BY,  init_data_profile.UPDATED_BY,  init_data_profile.IS_ACTIVE,  init_data_profile.REMARK,  init_data_profile.LUCKY_NUMBER,  init_data_profile.LUCKY_NUMBER_LEVEL,  init_data_profile.NON_CHARGE,  init_data_profile.OWNER,  init_data_profile.PAYMENT_MODE,  init_data_profile.SALE_CHANEL,  init_data_profile.STATUS,  init_data_profile.MASTER_ID,  init_data_profile.FLAG_VIP,  init_data_profile.PREVIOUS_STATUS,  init_data_profile.STATUS_BEFORE_PREVIOUS,  init_data_profile.OM_OWNER,  init_data_profile.OM_RESERVED_TYPE,  init_data_profile.OM_RESERVED_DATE,  init_data_profile.IS_TER_OCS  );

--          EXCEPTION   
--            WHEN others THEN 
--              DBMS_OUTPUT.PUT_LINE( 'err : ' || DAT.EXTERNAL_ID);
          END;
         END LOOP;
--        DBMS_OUTPUT.PUT_LINE('C_MAIN_DATA : ' || C_MAIN_DATA%ROWCOUNT);
        if C_MAIN_DATA%ROWCOUNT = 0 then
           V_ENDLOOP := TRUE;
--           DBMS_OUTPUT.PUT_LINE('End Loooooop');
        end if;
         CLOSE C_MAIN_DATA;
         commit;
--      ELSE
--        V_ENDLOOP := TRUE;
--     
--      END IF;


    END;


  END LOOP;
  DBMS_OUTPUT.PUT_LINE( 'End' || to_char(sysdate , 'dd/mm/yyyy hh24:mi'));


END MIGRATE_INV_MASTER_2;
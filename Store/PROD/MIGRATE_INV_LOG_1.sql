create or replace PROCEDURE MIGRATE_INV_LOG_1 AS 
  V_LIMITLOOP NUMBER(10) := 10000;
  V_COUNT_ALL_DATA NUMBER := 99999999;
  V_COUNT_NEW NUMBER := 0;
  V_DIFF number(16,0) := 0;
  V_ENDLOOP BOOLEAN := FALSE;
  CURSOR C_MAIN_DATA IS
SELECT ROWID ID_ , view_id ,INVENTORY_ID, STATUS_ID  , SECONDARY_CODE  , EXTERNAL_ID , INVENTORY_TYPE_ID , START_DATE_TIME , END_DATE_TIME from TRMP_MIGRATE_LOG2
   WHERE MIGRATE_LOG = 1
   AND ROWNUM <= V_LIMITLOOP;
   V_PREFIX_VIEW_ID VARCHAR(30) := 'MGT_'||TO_CHAR(SYSDATE , 'YYYYMMDD')||'_';
   
   
  V_COUNT_INV_MAIN NUMBER:= 0;
  V_INVENTORY_TYPE_ID varchar(10) := null;
  V_SECONDARY_CODE varchar(30) := null;
  V_EXTERNAL_ID varchar(30) := null;
  
  init_data invuser.INV_LOG_NUMBER%ROWTYPE;
  DAT C_MAIN_DATA%ROWTYPE; 
BEGIN
 
   DBMS_OUTPUT.PUT_LINE( 'START MIGRATE_INV_LOG_1 : ' || to_char(sysdate , 'dd/mm/yyyy hh24:mi'));

    WHILE V_ENDLOOP = FALSE
    LOOP
      
      
      OPEN C_MAIN_DATA;
--         DBMS_OUTPUT.PUT_LINE('C_MAIN_DATA : ' || C_MAIN_DATA%ROWCOUNT);
         LOOP
          FETCH C_MAIN_DATA INTO DAT;
          EXIT WHEN C_MAIN_DATA%NOTFOUND;
 
          INSERT INTO INVUSER.INV_LOG (ACTION ,BULK_ID ,CREATED_BY ,CREATED_DATE ,EXECUTE_DATE ,EXECUTE_TIME ,ID ,ORDER_ID ,ORDER_STATUS ,TOTAL ,TOTAL_FAIL ,TOTAL_SUCCESS ,UPDATED_BY ,UPDATED_DATE)
          VALUES (2 , NULL , 'Migration' , DAT.START_DATE_TIME ,NULL ,NULL , invuser.INVLOG_SEQ.nextval , V_PREFIX_VIEW_ID||DAT.view_id ,1,1,0,1 ,NULL,DAT.END_DATE_TIME  );
          
          
          init_data.ID := INVUSER.INVLOGNUMBER_SEQ.NEXTVAL;
          init_data.MAPPING_STATUS := NULL;
          init_data.MODIFY_DATE := SYSDATE;
          init_data.ORDER_ID := V_PREFIX_VIEW_ID||DAT.view_id ;
          init_data.REMARK := NULL;
          init_data.RESULT := 'success';
          IF DAT.INVENTORY_TYPE_ID = '101' THEN
          
          
            init_data.ICCID := DAT.SECONDARY_CODE;
            init_data.IMSI := DAT.EXTERNAL_ID;
            init_data.MSISDN := NULL;
            
         
            ELSIF DAT.INVENTORY_TYPE_ID = '201' THEN
              init_data.ICCID := NULL;
              init_data.IMSI := NULL;
              init_data.MSISDN := DAT.EXTERNAL_ID;
          
          END IF;
          
           init_data.STATUS_PREVIOUS := null;
          begin
            SELECT STATUS_ID INTO init_data.STATUS_PREVIOUS FROM (
              SELECT STATUS_ID  FROM INVD_VIEWS V WHERE V.INVENTORY_ID = DAT.INVENTORY_ID AND V.VIEW_ID > DAT.VIEW_ID ORDER BY VIEW_ID DESC
            )WHERE ROWNUM <= 1;
          EXCEPTION   
            WHEN others THEN 
--              DBMS_OUTPUT.PUT_LINE( 'err : ' || DAT.EXTERNAL_ID);
            init_data.STATUS_PREVIOUS := null;
          end;
          
          INSERT INTO INVUSER.INV_LOG_NUMBER ( ID, ORDER_ID, MSISDN, ICCID, STATUS, RESULT, REMARK, IMSI, MAPPING_STATUS, MODIFY_DATE, BULK_ID, STATUS_PREVIOUS ) 
          VALUES ( init_data.ID, init_data.ORDER_ID, init_data.MSISDN, init_data.ICCID, dat.STATUS_ID, init_data.RESULT, init_data.REMARK, init_data.IMSI, init_data.MAPPING_STATUS, init_data.MODIFY_DATE, init_data.BULK_ID, init_data.STATUS_PREVIOUS );
          UPDATE TRMP_MIGRATE_LOG2 SET MIGRATE_LOG = 9 WHERE ROWID = DAT.ID_;

      END LOOP;
      if C_MAIN_DATA%ROWCOUNT = 0 then
         V_ENDLOOP := TRUE;
--           DBMS_OUTPUT.PUT_LINE('End Loooooop');
      end if;
       CLOSE C_MAIN_DATA;
      COMMIT;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE( 'End' || to_char(sysdate , 'dd/mm/yyyy hh24:mi'));
END MIGRATE_INV_LOG_1;
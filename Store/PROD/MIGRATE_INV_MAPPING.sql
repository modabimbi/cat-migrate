create or replace PROCEDURE MIGRATE_INV_MAPPING AS 

 V_LIMITLOOP NUMBER:= 20000;
 V_ENDLOOP BOOLEAN := FALSE;
 V_COUNT_NEW number(16,0) := 0;
 V_COUNT_MAIN number(6,0) := 0;
 

 V_DIFF number(16,0) := 0;
 init_data invuser.INV_MAPPING%ROWTYPE;
 CURSOR C_MAIN_DATA IS
  select A.Range_Map_External_ID , A.ADDTL_NOTIF_EXTERNAL_ID , a.rowid
    from ACCOUNT_SUBSCRIBER A 
    where ADDTL_NOTIF_EXTERNAL_ID is not null
    and A.MIGRATE is null
    and rowNum <= V_LIMITLOOP;
 DAT C_MAIN_DATA%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE( 'START MIGRATE_INV_MAPPING : ' || to_char(sysdate , 'dd/mm/yyyy hh24:mi'));
    WHILE V_ENDLOOP = FALSE
    LOOP

       begin
       
        OPEN C_MAIN_DATA;
--         DBMS_OUTPUT.PUT_LINE('C_MAIN_DATA : ' || C_MAIN_DATA%ROWCOUNT);
        LOOP
          FETCH C_MAIN_DATA INTO DAT;
          EXIT WHEN C_MAIN_DATA%NOTFOUND;
          
            init_data.CREATED_BY := 'Migration';
            init_data.CREATED_DATE := SYSDATE;
            
            init_data.IMSI := DAT.ADDTL_NOTIF_EXTERNAL_ID;
            init_data.IS_ACTIVE := 'Y';
            init_data.MAPPING_STATUS := NULL;
            init_data.MULTISIM_FLAG := 1;
            init_data.REMARK := NULL;
            select invuser.INVMAPPING_SEQ.nextval into init_data.MAPPING_ID from dual;
            init_data.UPDATED_BY := null;
            init_data.UPDATED_DATE := null;
            init_data.SECONDARY_CODE := null;
            
            IF SUBSTR(DAT.Range_Map_External_ID , 1 ,2) = '66' THEN
              init_data.EXTERNAL_ID := SUBSTR(DAT.Range_Map_External_ID , 3 ,LENGTH(DAT.Range_Map_External_ID) - 2);
            ELSE 
              init_data.EXTERNAL_ID := DAT.Range_Map_External_ID;
            END IF;
            
            select count(1) into V_COUNT_MAIN from INVD_MAIN where EXTERNAL_ID = DAT.ADDTL_NOTIF_EXTERNAL_ID and INVENTORY_TYPE_ID = '101';
            if V_COUNT_MAIN > 0 then
              select SECONDARY_CODE into init_data.SECONDARY_CODE from INVD_MAIN where EXTERNAL_ID = DAT.ADDTL_NOTIF_EXTERNAL_ID and INVENTORY_TYPE_ID = '101';
            
            end if;
            INSERT INTO invuser.INV_MAPPING 
            ( MAPPING_ID, CREATED_DATE, UPDATED_DATE, CREATED_BY, UPDATED_BY, IS_ACTIVE, REMARK, EXTERNAL_ID, MAPPING_STATUS, MULTISIM_FLAG, SECONDARY_CODE, IMSI ) 
            VALUES 
            ( init_data.MAPPING_ID, init_data.CREATED_DATE, init_data.UPDATED_DATE, init_data.CREATED_BY, init_data.UPDATED_BY, init_data.IS_ACTIVE, init_data.REMARK, init_data.EXTERNAL_ID, init_data.MAPPING_STATUS, init_data.MULTISIM_FLAG, init_data.SECONDARY_CODE, init_data.IMSI );
            update ACCOUNT_SUBSCRIBER set MIGRATE = 'Y' where ROWID = dat.rowid;
         END LOOP;
          IF C_MAIN_DATA%ROWCOUNT = 0 then
             V_ENDLOOP := TRUE;
          END IF;
         CLOSE C_MAIN_DATA;
         commit;
         end;
     END LOOP;
     DBMS_OUTPUT.PUT_LINE( 'End' || to_char(sysdate , 'dd/mm/yyyy hh24:mi'));
END MIGRATE_INV_MAPPING;

  CREATE TABLE "INVUSER"."INV_MASTER" 
   (	"MASTER_ID" NUMBER(19,0) NOT NULL ENABLE, 
	"CREATED_DATE" TIMESTAMP (6), 
	"UPDATED_DATE" TIMESTAMP (6), 
	"CREATED_BY" VARCHAR2(255 BYTE), 
	"UPDATED_BY" VARCHAR2(255 BYTE), 
	"IS_ACTIVE" VARCHAR2(1 BYTE) DEFAULT 'Y', 
	"REMARK" VARCHAR2(1500 BYTE), 
	"DIGIT" NUMBER(10,0), 
	"EXTERNAL_ID" VARCHAR2(30 CHAR), 
	"EXTN_ID_TYPE" VARCHAR2(3 BYTE) NOT NULL ENABLE, 
	"IMSI" VARCHAR2(30 CHAR), 
	"MVNO_ID" VARCHAR2(3 BYTE), 
	"NUMBER_TYPE" VARCHAR2(2 BYTE), 
	"OPERATOR_ID" VARCHAR2(3 BYTE), 
	"PIN1" VARCHAR2(8 BYTE), 
	"PIN2" VARCHAR2(8 BYTE), 
	"PUK1" VARCHAR2(8 BYTE), 
	"PUK2" VARCHAR2(8 BYTE), 
	"SECONDARY_CODE" VARCHAR2(30 CHAR), 
	"SIM_CODE" VARCHAR2(50 BYTE), 
	"SIM_FLAG" NUMBER(10,0), 
	"ZONE_ID" VARCHAR2(25 BYTE), 
	 PRIMARY KEY ("MASTER_ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "INV_DATA"  ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "INV_DATA" ;

  CREATE INDEX "INVUSER"."INV_MASTER_IDX" ON "INVUSER"."INV_MASTER" ("EXTERNAL_ID", "SECONDARY_CODE") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "INV_DATA" ;
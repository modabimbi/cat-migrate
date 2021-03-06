CREATE SEQUENCE TEST_INVMASTER_SEQ;
CREATE SEQUENCE TEST_INVMAPPING_SEQ;
CREATE SEQUENCE TEST_INVMASTERPROFILE_SEQ;
CREATE SEQUENCE TEST_INVLOG_SEQ;
CREATE SEQUENCE TEST_INVLOGNUMBER_SEQ;

grant select on TEST_INVMASTER_SEQ To invmig;
grant select on TEST_INVMAPPING_SEQ To invmig;
grant select on TEST_INVMASTERPROFILE_SEQ To invmig;
grant select on TEST_INVLOG_SEQ To invmig;
grant select on TEST_INVLOGNUMBER_SEQ To invmig;


GRANT ALL ON TEST_INV_MAPPING TO invmig;
GRANT ALL ON TEST_INV_MASTER TO invmig;
GRANT ALL ON TEST_INV_MASTER_PROFILE TO invmig;
GRANT ALL ON TEST_INV_LOG TO invmig;
GRANT ALL ON TEST_INV_LOG_NUMBER TO invmig;
CREATE INDEX TEST_INV_MAPPING_INDEX1 ON TEST_INV_MAPPING (EXTERNAL_ID, IMSI);

ALTER TABLE TEST_INV_LOG_NUMBER MODIFY (STATUS VARCHAR2(3 BYTE) );
ALTER TABLE TEST_INV_LOG_NUMBER MODIFY (STATUS_PREVIOUS VARCHAR2(3 BYTE) );
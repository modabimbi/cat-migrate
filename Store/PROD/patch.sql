update INVUSER.INV_MASTER_PROFILE 
set STATUS = '16'
where rowid in(select  p.rowid  
from INVUSER.INV_MASTER m
join ACCOUNT_SUBSCRIBER r 
on m.IMSI = r.ADDTL_NOTIF_EXTERNAL_ID
join INVUSER.INV_MASTER_PROFILE p
on p.MASTER_ID = m.MASTER_ID
where CURRENT_STATE = 3
and PAYMENT_MODE1 = 1) ;


update INVUSER.INV_MASTER_PROFILE 
set STATUS = '1'
where rowid in(
select  p.rowid  
from INVUSER.INV_MASTER m
join INVUSER.INV_MASTER_PROFILE p
on p.MASTER_ID = m.MASTER_ID
where m.EXTN_ID_TYPE = '201'
and p.STATUS = '8'
and p.PAYMENT_MODE = '1'
);
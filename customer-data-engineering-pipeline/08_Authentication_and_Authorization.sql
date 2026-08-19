select
    suser_sname() as current_login,
    auth_scheme
from sys.dm_exec_connections
where session_id = @@spid;

select serverproperty('IsIntegratedSecurityOnly') as windows_only;

select @@version;

create login etl_user
with password = 'Daisy@Nick2001';

use DataEngineeringProject1;

create user etl_user
for login etl_user;

use SalesDB;

create user etl_user
for login etl_user;

use SalesDB;

grant select
on dbo.Customers
to etl_user;

use DataEngineeringProject1;

grant execute
on dbo.usp_load_customers
to etl_user;

grant select, insert, update
on staging.Customers
to etl_user;

use DataEngineeringProject1;

grant select, insert, update
on dbo.pipeline_log
to etl_user;
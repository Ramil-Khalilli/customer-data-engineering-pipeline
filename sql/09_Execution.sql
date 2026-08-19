use DataEngineeringProject1;

exec dbo.usp_load_customers;

select * from dbo.pipeline_log order by run_id desc;
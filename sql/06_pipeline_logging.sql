use DataEngineeringProject1;

-- ============================================================
-- create pipeline execution log
-- ============================================================

create table dbo.pipeline_log
(
    run_id bigint identity(1,1) primary key,
    pipeline_name varchar(100) not null,
    start_time datetime2 not null,
    end_time datetime2 null,
    status varchar(20) not null,
    rows_inserted int null,
    rows_updated int null,
    rows_deleted int null,
    error_message varchar(4000) null
);



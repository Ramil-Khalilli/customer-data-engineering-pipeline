use DataEngineeringProject1;
go

create or alter procedure dbo.usp_load_customers
as
begin
    set nocount on;

    -- pipeline logic:
    declare @rows_inserted int = 0;
    declare @rows_updated int = 0;
    declare @rows_deleted int = 0;

    declare @run_id bigint;
    declare @start_time datetime2 = sysdatetime();

    insert into dbo.pipeline_log
    (
        pipeline_name,
        start_time,
        status
    )
    values
    (
        'customer_incremental_load',
        @start_time,
        'running');

    set @run_id = scope_identity();

    begin try
        begin transaction;
        -- ============================================================
        -- prepare source
        -- ============================================================

        drop table if exists #source_prepared;

        select
            CustomerID,
            CustomerName,
            BirthDate,
            Gender,
            MaritalStatus,
            TotalChildren,
            HouseOwnerFlag,
            NumberCarsOwned,
            Education,
            Occupation,
            Continent,
            Country,
            State,
            City,
            YearlyIncome,
            DateFirstPurchase,
            convert(
                varchar(64),
                hashbytes(
                    'sha2_256',
                    concat(
                        CustomerName, '|',
                        BirthDate, '|',
                        Gender, '|',
                        MaritalStatus, '|',
                        TotalChildren, '|',
                        HouseOwnerFlag, '|',
                        NumberCarsOwned, '|',
                        Education, '|',
                        Occupation, '|',
                        Continent, '|',
                        Country, '|',
                        State, '|',
                        City, '|',
                        YearlyIncome, '|',
                        DateFirstPurchase
                    )
                ),
                2
            ) as row_hash
        into #source_prepared
        from SalesDB.dbo.Customers;


        -- ============================================================
        -- insert new customers
        -- ============================================================

        insert into staging.Customers
        (
            CustomerID,
            CustomerName,
            BirthDate,
            Gender,
            MaritalStatus,
            TotalChildren,
            HouseOwnerFlag,
            NumberCarsOwned,
            Education,
            Occupation,
            Continent,
            Country,
            State,
            City,
            YearlyIncome,
            DateFirstPurchase,
            row_hash,
            is_deleted
        )
        select
            n.CustomerID,
            n.CustomerName,
            n.BirthDate,
            n.Gender,
            n.MaritalStatus,
            n.TotalChildren,
            n.HouseOwnerFlag,
            n.NumberCarsOwned,
            n.Education,
            n.Occupation,
            n.Continent,
            n.Country,
            n.State,
            n.City,
            n.YearlyIncome,
            n.DateFirstPurchase,
            n.row_hash,
            0
        from #source_prepared n
        left join staging.Customers s
            on n.CustomerID = s.CustomerID
        where s.CustomerID is null;

        set @rows_inserted = @@rowcount;

        -- ============================================================
        -- update changed customers
        -- ============================================================

        update s
        set
            s.CustomerName = n.CustomerName,
            s.BirthDate = n.BirthDate,
            s.Gender = n.Gender,
            s.MaritalStatus = n.MaritalStatus,
            s.TotalChildren = n.TotalChildren,
            s.HouseOwnerFlag = n.HouseOwnerFlag,
            s.NumberCarsOwned = n.NumberCarsOwned,
            s.Education = n.Education,
            s.Occupation = n.Occupation,
            s.Continent = n.Continent,
            s.Country = n.Country,
            s.State = n.State,
            s.City = n.City,
            s.YearlyIncome = n.YearlyIncome,
            s.DateFirstPurchase = n.DateFirstPurchase,
            s.row_hash = n.row_hash,
            s.is_deleted = 0
        from staging.Customers s
        join #source_prepared n
            on s.CustomerID = n.CustomerID
        where s.row_hash <> n.row_hash
           or s.is_deleted = 1;

        set @rows_updated = @@rowcount;

        -- ============================================================
        -- soft delete customers missing from source
        -- ============================================================

        update s
        set
            s.is_deleted = 1
        from staging.Customers s
        left join #source_prepared n
            on s.CustomerID = n.CustomerID
        where n.CustomerID is null
          and s.is_deleted = 0;

        set @rows_deleted = @@rowcount;

        -- ============================================================
        -- validation
        -- ============================================================

        select
            count(*) as total_rows,
            sum(case when is_deleted = 0 then 1 else 0 end) as active_rows,
            sum(case when is_deleted = 1 then 1 else 0 end) as deleted_rows
        from staging.Customers;


        select
            CustomerID,
            count(*) as row_count
        from staging.Customers
        group by CustomerID
        having count(*) > 1;


        select
            s.CustomerID
        from staging.Customers s
        left join #source_prepared n
            on s.CustomerID = n.CustomerID
        where s.is_deleted = 0
          and n.CustomerID is null;


        select
            n.CustomerID
        from #source_prepared n
        left join staging.Customers s
            on n.CustomerID = s.CustomerID
        where s.CustomerID is null
           or s.is_deleted = 1;

        select
            @run_id as run_id,
            @rows_inserted as rows_inserted,
            @rows_updated as rows_updated,
            @rows_deleted as rows_deleted;

        commit transaction;

        update dbo.pipeline_log
            set
                end_time = sysdatetime(),
                status = 'success',
                rows_inserted = @rows_inserted,
                rows_updated = @rows_updated,
                rows_deleted = @rows_deleted
            where run_id = @run_id;

            end try
            begin catch

                if @@trancount > 0
                    rollback transaction;

                update dbo.pipeline_log
                set
                    end_time = sysdatetime(),
                    status = 'failed',
                    error_message = error_message()
                where run_id = @run_id;

                throw;

    end catch;

end;
go

exec dbo.usp_load_customers;
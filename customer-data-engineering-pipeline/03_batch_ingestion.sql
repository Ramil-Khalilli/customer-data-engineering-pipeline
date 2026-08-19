-- ============================================================
-- 03_batch_ingestion.sql
-- Purpose: Full batch ingestion from source to raw layer
-- ============================================================
use DataEngineeringProject1;

truncate table raw.Customers;

insert into raw.Customers
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
    DateFirstPurchase
)
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
    DateFirstPurchase
from SalesDB.dbo.Customers;

select count(*) as row_count from raw.Customers;

select
    column_name,
    data_type
from SalesDB.information_schema.columns
where table_schema = 'dbo'
  and table_name = 'Customers'
order by ordinal_position;

select
    CustomerID,
    CustomerName,
    Country,
    convert(varchar(64),
        hashbytes(
            'sha2_256',
            concat(
                CustomerName,
                '|',
                Country
            )
        ),
        2
    ) as row_hash
from SalesDB.dbo.Customers;

select * from raw.Customers;

create schema staging;

create table staging.Customers
(
    CustomerID          int,
    CustomerName        nvarchar(150),
    BirthDate           date,
    Gender              char(1),
    MaritalStatus       nvarchar(20),
    TotalChildren       int,
    HouseOwnerFlag      bit,
    NumberCarsOwned     int,
    Education           nvarchar(100),
    Occupation          nvarchar(100),
    Continent           nvarchar(50),
    Country             nvarchar(100),
    State                nvarchar(100),
    City                 nvarchar(100),
    YearlyIncome        decimal(18,2),
    DateFirstPurchase   date,
    row_hash            varchar(64)
);

select * from staging.Customers;


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
    row_hash
)
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
    )
from raw.Customers;

select top 10
    CustomerID,
    CustomerName,
    Country,
    row_hash
from staging.Customers;


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
    DateFirstPurchase
into #source_snapshot
from SalesDB.dbo.Customers;

select top 1
    CustomerID,
    CustomerName,
    Country
from #source_snapshot;


update #source_snapshot
set Country = 'Iceland'
where CustomerID = 11000;


select
    CustomerID,
    CustomerName,
    Country,
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
    ) as new_hash
from #source_snapshot
where CustomerID = 11000;

-- New Hash - 3E679923ACA81167C768E8CA4CAC1DF971CE6A25D6679C95BE4D7EF1735EB8A4

select * from staging.Customers where CustomerID = 11000;

-- Original Hash - 84AD26B26D22A8E274CB2E6C47A3E78AD34E870F4C7D1CDA7D1CAF7B6307923F

select
    s.CustomerID,
    s.Country as old_country,
    n.Country as new_country,
    s.row_hash as old_hash,
    convert(
        varchar(64),
        hashbytes(
            'sha2_256',
            concat(
                n.CustomerName, '|',
                n.BirthDate, '|',
                n.Gender, '|',
                n.MaritalStatus, '|',
                n.TotalChildren, '|',
                n.HouseOwnerFlag, '|',
                n.NumberCarsOwned, '|',
                n.Education, '|',
                n.Occupation, '|',
                n.Continent, '|',
                n.Country, '|',
                n.State, '|',
                n.City, '|',
                n.YearlyIncome, '|',
                n.DateFirstPurchase
            )
        ),
        2
    ) as new_hash
from staging.Customers s
join #source_snapshot n
    on s.CustomerID = n.CustomerID
where s.CustomerID = 11000;


select
    s.CustomerID,
    s.Country as old_country,
    n.Country as new_country,
    s.row_hash as old_hash,
    convert(
        varchar(64),
        hashbytes(
            'sha2_256',
            concat(
                n.CustomerName, '|',
                n.BirthDate, '|',
                n.Gender, '|',
                n.MaritalStatus, '|',
                n.TotalChildren, '|',
                n.HouseOwnerFlag, '|',
                n.NumberCarsOwned, '|',
                n.Education, '|',
                n.Occupation, '|',
                n.Continent, '|',
                n.Country, '|',
                n.State, '|',
                n.City, '|',
                n.YearlyIncome, '|',
                n.DateFirstPurchase
            )
        ),
        2
    ) as new_hash
from staging.Customers s
join #source_snapshot n
    on s.CustomerID = n.CustomerID
where s.CustomerID = 11000;


select
    count(*) as changed_customers
from staging.Customers s
join #source_snapshot n
    on s.CustomerID = n.CustomerID
where s.row_hash <>
    convert(
        varchar(64),
        hashbytes(
            'sha2_256',
            concat(
                n.CustomerName, '|',
                n.BirthDate, '|',
                n.Gender, '|',
                n.MaritalStatus, '|',
                n.TotalChildren, '|',
                n.HouseOwnerFlag, '|',
                n.NumberCarsOwned, '|',
                n.Education, '|',
                n.Occupation, '|',
                n.Continent, '|',
                n.Country, '|',
                n.State, '|',
                n.City, '|',
                n.YearlyIncome, '|',
                n.DateFirstPurchase
            )
        ),
        2
    );



select
    s.CustomerID
from staging.Customers s
join #source_snapshot n
    on s.CustomerID = n.CustomerID
where s.row_hash <>
    convert(
        varchar(64),
        hashbytes(
            'sha2_256',
            concat(
                n.CustomerName, '|',
                n.BirthDate, '|',
                n.Gender, '|',
                n.MaritalStatus, '|',
                n.TotalChildren, '|',
                n.HouseOwnerFlag, '|',
                n.NumberCarsOwned, '|',
                n.Education, '|',
                n.Occupation, '|',
                n.Continent, '|',
                n.Country, '|',
                n.State, '|',
                n.City, '|',
                n.YearlyIncome, '|',
                n.DateFirstPurchase
            )
        ),
        2
    );


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
    s.row_hash = convert(
        varchar(64),
        hashbytes(
            'sha2_256',
            concat(
                n.CustomerName, '|',
                n.BirthDate, '|',
                n.Gender, '|',
                n.MaritalStatus, '|',
                n.TotalChildren, '|',
                n.HouseOwnerFlag, '|',
                n.NumberCarsOwned, '|',
                n.Education, '|',
                n.Occupation, '|',
                n.Continent, '|',
                n.Country, '|',
                n.State, '|',
                n.City, '|',
                n.YearlyIncome, '|',
                n.DateFirstPurchase
            )
        ),
        2
    )
from staging.Customers s
join #source_snapshot n
    on s.CustomerID = n.CustomerID
where s.row_hash <>
    convert(
        varchar(64),
        hashbytes(
            'sha2_256',
            concat(
                n.CustomerName, '|',
                n.BirthDate, '|',
                n.Gender, '|',
                n.MaritalStatus, '|',
                n.TotalChildren, '|',
                n.HouseOwnerFlag, '|',
                n.NumberCarsOwned, '|',
                n.Education, '|',
                n.Occupation, '|',
                n.Continent, '|',
                n.Country, '|',
                n.State, '|',
                n.City, '|',
                n.YearlyIncome, '|',
                n.DateFirstPurchase
            )
        ),
        2
    );


select
    CustomerID,
    CustomerName,
    Country,
    row_hash
from staging.Customers
where CustomerID = 11000;



select max(CustomerID) as max_customer_id
from #source_snapshot;


insert into #source_snapshot
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
    DateFirstPurchase
)
values
(
    999999,
    'Test Customer',
    '1995-01-01',
    'M',
    'Single',
    0,
    0,
    0,
    'University',
    'Engineer',
    'Asia',
    'Azerbaijan',
    'Baku',
    'Baku',
    50000.00,
    '2026-08-16'
);


select
    n.CustomerID,
    n.CustomerName,
    n.Country
from #source_snapshot n
left join staging.Customers s
    on n.CustomerID = s.CustomerID
where s.CustomerID is null;




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
    row_hash
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
    convert(
        varchar(64),
        hashbytes(
            'sha2_256',
            concat(
                n.CustomerName, '|',
                n.BirthDate, '|',
                n.Gender, '|',
                n.MaritalStatus, '|',
                n.TotalChildren, '|',
                n.HouseOwnerFlag, '|',
                n.NumberCarsOwned, '|',
                n.Education, '|',
                n.Occupation, '|',
                n.Continent, '|',
                n.Country, '|',
                n.State, '|',
                n.City, '|',
                n.YearlyIncome, '|',
                n.DateFirstPurchase
            )
        ),
        2
    )
from #source_snapshot n
left join staging.Customers s
    on n.CustomerID = s.CustomerID
where s.CustomerID is null;



select
    CustomerID,
    CustomerName,
    Country,
    row_hash
from staging.Customers
where CustomerID = 999999;



delete from #source_snapshot
where CustomerID = 999999;


select
    s.CustomerID,
    s.CustomerName,
    s.Country
from staging.Customers s
left join #source_snapshot n
    on s.CustomerID = n.CustomerID
where n.CustomerID is null;



use DataEngineeringProject1;

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
    Country
from staging.Customers
where CustomerID = 11000;


select
    CustomerID,
    CustomerName,
    Country
from #source_snapshot
where CustomerID = 11000;


update #source_snapshot
set Country = 'Iceland'
where CustomerID = 11000;


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
    ),
    s.is_deleted = 0
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
    )
    or s.is_deleted = 1;


select
    CustomerID,
    CustomerName,
    Country
from staging.Customers
where CustomerID = 11000;



-- ============================================================
-- detect deleted customers
-- ============================================================

select
    s.CustomerID,
    s.CustomerName
from staging.Customers s
left join #source_snapshot n
    on s.CustomerID = n.CustomerID
where n.CustomerID is null;


alter table staging.Customers
add is_deleted bit not null
    constraint df_staging_customers_is_deleted default 0;


update s
set
    s.is_deleted = 1
from staging.Customers s
left join #source_snapshot n
    on s.CustomerID = n.CustomerID
where n.CustomerID is null
  and s.is_deleted = 0;


select
    CustomerID,
    CustomerName,
    Country,
    is_deleted
from staging.Customers
where CustomerID = 999999;


-- ============================================================
-- validation
-- ============================================================

select
    count(*) as staging_rows,
    sum(case when is_deleted = 0 then 1 else 0 end) as active_rows,
    sum(case when is_deleted = 1 then 1 else 0 end) as deleted_rows
from staging.Customers;


select
    CustomerID,
    count(*) as row_count
from staging.Customers
group by CustomerID
having count(*) > 1;



-- ============================================================
-- source vs staging validation
-- ============================================================

select
    n.CustomerID
from #source_snapshot n
left join staging.Customers s
    on n.CustomerID = s.CustomerID
where s.CustomerID is null
   or s.is_deleted = 1;


select
    s.CustomerID
from staging.Customers s
left join #source_snapshot n
    on s.CustomerID = n.CustomerID
where n.CustomerID is null
  and s.is_deleted = 0;
-- ============================================================
-- 02_create_data_platform.sql
-- Purpose: Create the destination database for our data platform
-- ============================================================

create database DataEngineeringProject1;

use DataEngineeringProject1;

create schema raw;

use SalesDB;

exec sp_help 'dbo.Customers';

use DataEngineeringProject1;

create table raw.Customers
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
    State               nvarchar(100),
    City                nvarchar(100),
    YearlyIncome        decimal(18,2),
    DateFirstPurchase   date
);

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

select 'Raw' as table_name, count(*) as rows from raw.Customers

union all

select 'Source', count(*) from SalesDB.dbo.Customers;

select
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
from SalesDB.information_schema.columns
where table_schema = 'dbo'
  and table_name = 'Customers'
order by ordinal_position;

select
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
from DataEngineeringProject1.information_schema.columns
where table_schema = 'raw'
  and table_name = 'Customers'
order by ordinal_position;

select
    count(*) as row_count,
    count(distinct CustomerID) as distinct_customers,
    sum(cast(CustomerID as bigint)) as customer_id_sum
from SalesDB.dbo.Customers;

select
    count(*) as row_count,
    count(distinct CustomerID) as distinct_customers,
    sum(cast(CustomerID as bigint)) as customer_id_sum
from DataEngineeringProject1.raw.Customers;
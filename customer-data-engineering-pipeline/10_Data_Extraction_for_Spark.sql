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
from staging.Customers
where is_deleted = 0;
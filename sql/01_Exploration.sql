----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- 1. Exploring the dimentions of the talbes.
select
	r.table_name,
	r.row_count,
	c.column_count
from (select
		'Customers' as table_name, count(*) as row_count
	from Customers


	union all

	select
		'Products', count(*)
	from Products

	union all

	select
		'Reseller', count(*)
	from Reseller

	union all

	select
		'ResellerSales', count(*)
	from ResellerSales

	union all

	select
		'InternetSales', count(*)
	from InternetSales) as r

join (select 
		TABLE_NAME as table_name,
		count(*) as column_count
	from INFORMATION_SCHEMA.COLUMNS
	group by TABLE_NAME) as c
on r.table_name = c.table_name;



----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

-- 2. Information about the columns.
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
	IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN (
      'Customers',
      'Products',
      'InternetSales',
      'Reseller',
      'ResellerSales',
      'Calendar'
  )
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;


----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- 3. Approximate table size.
SELECT
    t.name AS table_name,
    SUM(p.rows) AS row_count,
    SUM(a.total_pages) * 8 AS total_space_kb
FROM sys.tables t
JOIN sys.indexes i
    ON t.object_id = i.object_id
JOIN sys.partitions p
    ON i.object_id = p.object_id
    AND i.index_id = p.index_id
JOIN sys.allocation_units a
    ON p.partition_id = a.container_id
WHERE t.name IN (
    'Customers',
    'Products',
    'InternetSales',
    'Reseller',
    'ResellerSales',
    'Calendar'
)
GROUP BY t.name
ORDER BY total_space_kb DESC;


----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- 4. Keys and Relationships.
SELECT
    fk.name AS foreign_key_name,
    OBJECT_NAME(fk.parent_object_id) AS child_table,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS child_column,
    OBJECT_NAME(fk.referenced_object_id) AS parent_table,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS parent_column
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
ORDER BY child_table, foreign_key_name;



SELECT
    fk.name AS foreign_key_name,
    OBJECT_NAME(fk.parent_object_id) AS child_table,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS child_column,
    OBJECT_NAME(fk.referenced_object_id) AS parent_table,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS parent_column
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'ResellerSales'
ORDER BY fk.name;

-- NOTE:
-- ResellerSales has two foreign-key constraints referencing
-- Products.ProductID:
--   FK_ResellerSales_ProductID
--   FK_ResellerSales_Products
-- This appears redundant and should be investigated before
-- making any schema changes.

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- 5. 
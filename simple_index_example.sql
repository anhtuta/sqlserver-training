SET STATISTICS IO ON;
USE BikeStores;

CREATE INDEX idx_customer_city
ON sales.customers(city);

-- NonClustered index seek. This query takes advantage of index on city column
-- because it only returns a little percent or rows (2 rows)
SELECT first_name, last_name
FROM sales.customers c
WHERE c.city = 'Mountain View'

-- Clustered index scan, and it doesn't use index on city column,
-- because this query return more rows than previous query (10 rows)
SELECT customer_id, city
FROM sales.customers c
WHERE c.city = 'Spring Valley'

-- NonClustered index seek, this time it uses index on city column
-- because we select only PK and city column, so it can get enough data
-- on NonClustered index tree
SELECT customer_id, city
FROM sales.customers c
WHERE c.city = 'Spring Valley'

-- We want the second query will take advantage of index seek, try to
-- create covering index:
CREATE INDEX idx_customer_city
ON sales.customers(city)
INCLUDE(first_name, last_name)
WITH(DROP_EXISTING = ON)

-- Now it takes advantage of index seek
SELECT customer_id, city
FROM sales.customers c
WHERE c.city = 'Spring Valley'
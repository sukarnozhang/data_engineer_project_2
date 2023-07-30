--Find effectiveness of each sales person based on count of customers handling by grouping by gender and per salespersonid to provide meaningful insights to boost sales.

with persons_identity as (
	select businessentityid,
    gender
	from {{ source("AIRBYTE_SCHEMA","employee") }}
),
targeted_sales_orders as (
	select
		salespersonid,
		customerid
	from {{ source("AIRBYTE_SCHEMA","salesorderheader") }}
	where orderdate >= '2013-01-01' and orderdate < '2014-01-01'
)
SELECT
	count(customerid) as count_of_customers,
	tso.salespersonid as salesid,
	fe.gender as gen
from targeted_sales_orders tso
	inner join persons_identity fe
	on tso.salespersonid = fe.businessentityid
group by fe.gender, tso.salespersonid


-- Calculate salesperson effectiveness based on the number of customers handled
-- Grouped by salesperson ID and customer gender to provide insights for boosting sales

-- Step 1: Get employee details including gender for each salesperson
with persons_identity as (
    select
        businessentityid,   
        gender              
    from {{ source("AIRBYTE_SCHEMA", "employee") }}
),

-- Step 2: Get sales orders placed within the year 2013
targeted_sales_orders as (
    select
        salespersonid,      
        customerid          
    from {{ source("AIRBYTE_SCHEMA", "salesorderheader") }}
    where orderdate >= '2013-01-01' 
      and orderdate < '2014-01-01'
)

-- Step 3: Aggregate the count of customers per salesperson and gender
select
    count(distinct customerid) as count_of_customers,   
    tso.salespersonid as salesid,                       
    pi.gender as gen                                     
from targeted_sales_orders tso
inner join persons_identity pi
    on tso.salespersonid = pi.businessentityid
group by           
    pi.gender, 
    tso.salespersonid

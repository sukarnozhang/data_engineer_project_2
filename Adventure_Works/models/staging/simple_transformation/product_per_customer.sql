-- Count of products ordered by each customer
-- This model calculates how many products each customer has ordered
-- by counting product entries linked to their sales orders.

{{ 
    config(
        materialized = "table",
        database = "AIRBYTE_DATABASE",
        schema = "AIRBYTE_SCHEMA"
    ) 
}}

-- Get unique customer IDs from the source customer table
with customer_id as (
    select 
        customerid
    from {{ source("AIRBYTE_SCHEMA", "customer") }}
),

-- Get mapping of customer IDs to their respective sales order IDs
salesperson_order_header as (
    select 
        customerid,
        salesorderid
    from {{ source("AIRBYTE_SCHEMA", "salesorderheader") }}
),

-- Get mapping of sales orders to product IDs
sales_order_detail as (
    select 
        salesorderid,
        productid
    from {{ source("AIRBYTE_SCHEMA", "salesorderdetail") }}
)

-- Join all tables to compute the count of products per customer
select
    c.customerid,
    
    -- Count the number of product entries linked to this customer
    count(sod.productid) as count_of_products

from customer_id as ci
inner join salesperson_order_header as soh
    on ci.customerid = so.customerid
inner join sales_order_detail as sod
    on sod.salesorderid = soh.salesorderid

group by 
    ci.customerid

-- Salesperson commission and product count by sales order
-- This model calculates:
--   1. The average commission percentage earned by each salesperson per sales order.
--   2. The total count of products in each sales order.
--   3. A bonus value computed using a custom macro based on product count and commission.

{{
    config(
        materialized = "table",
        database = "AIRBYTE_DATABASE",
        schema = "AIRBYTE_SCHEMA"
    )
}}

-- Step 1: Retrieve commission percentages for each salesperson
with salesperson_commission as (
    select 
        businessentityid,     
        commissionpct        
    from {{ source("AIRBYTE_SCHEMA", "salesperson") }}
),

-- Step 2: Retrieve mapping between salespersons and their sales orders
salesperson_order_header as (
    select 
        salespersonid,        
        salesorderid          
    from {{ source("AIRBYTE_SCHEMA", "salesorderheader") }}
),

-- Step 3: Retrieve product details for each sales order
sales_order_detail as (
    select 
        salesorderid,         
        productid            
    from {{ source("AIRBYTE_SCHEMA", "salesorderdetail") }}
)

-- Step 4: Aggregate data to calculate commission, product count, and bonus per sales order and salesperson
select 
    sc.businessentityid,
    
    -- Average commission percentage for the salesperson on this sales order
    avg(sc.commissionpct) as commission,

    -- Total number of products included in the sales order
    count(sod.productid) as count_of_product,

    -- Identifier for the sales order
    sod.salesorderid as sales_order_id,

    -- Calculate bonus using a custom macro, passing in product count and commission
    {{ salesperson_commission('count_of_product', 'commission') }} as bonus

from salesperson_commission as sc

-- Join salesperson commission data with their associated sales orders
inner join salesperson_order_header as soh
    on sc.businessentityid = soh.salespersonid

-- Join sales orders to their product details
inner join sales_order_detail as sod
    on sod.salesorderid = soh.salesorderid

-- Group results by salesperson and sales order to aggregate commission and product counts
group by 
    sc.businessentityid,
    sod.salesorderid

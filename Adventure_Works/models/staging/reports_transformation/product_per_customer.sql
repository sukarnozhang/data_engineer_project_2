--products classified by customer as count_of_products
{{
    config(
            materialized = "table",
            database = "AIRBYTE_DATABASE",
            schema = "AIRBYTE_SCHEMA"
    )
 }}
with customer_id as(
    select customerid
    from {{ source("AIRBYTE_SCHEMA","customer") }}
),
salesperson_order_header as(
    select customerid,
    salesorderid
    from {{ source("AIRBYTE_SCHEMA","salesorderheader") }}
),
sales_order_detail as(
    select salesorderid,
    productid
    from {{ source("AIRBYTE_SCHEMA","salesorderdetail") }}
)


select
    c.customerid,
    sum(sd.productid) as sum_of_product
from
    customer_id as c
    inner join salesperson_order_header as so
    on c.customerid = so.customerid
    inner join sales_order_detail as sd
    on sd.salesorderid = so.salesorderid
group by c.customerid
--salesperson commision on productid
 
 {{
    config(
            materialized = "table",
            database = "AIRBYTE_DATABASE",
            schema = "AIRBYTE_SCHEMA"
    )
 }}
 
with salesperson_commission as(
    select businessentityid,
    commissionpct
    from {{ source("AIRBYTE_SCHEMA","salesperson")}}
),
salesperson_order_header as(
    select salespersonid,
    salesorderid
    from  {{ source("AIRBYTE_SCHEMA","salesorderheader") }}
),
sales_order_detail as(
    select salesorderid,
    productid
    from  {{ source("AIRBYTE_SCHEMA","salesorderdetail") }}
)
SELECT 
    sum(sc.commissionpct) as commission,
    count(sd.productid) as count_of_product,
    sd.salesorderid as sales_order_id,
    {{ salesperson_commission( 'count_of_product' , 'commission') }} as bonus
from
    salesperson_commission as sc
    inner join salesperson_order_header as so
    on sc.businessentityid=so.salespersonid
    inner join sales_order_detail as sd
    on sd.salesorderid = so.salesorderid
group by sc.businessentityid, sd.salesorderid
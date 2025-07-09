-- Combine sales order header and detail data to create a fact table with surrogate keys for analytics

-- CTE: salesorderheader
-- Selects key fields from the staged sales order header model and formats the order date
with salesorderheader as (
    select
        salesorderid,
        customerid,
        creditcardid,
        shiptoaddressid,
        order_status,
        date(stg_salesorderheader.orderdate) as orderdate
    from {{ ref('stg_salesorderheader') }}
)

-- CTE: salesorderdetail
-- Selects line-item level sales details and calculates total price per item (unitprice * quantity)
, salesorderdetail as (
    select
        salesorderid,
        salesorderdetailid,
        productid,
        orderqty,
        unitprice,
        unitprice * orderqty as qty_price
    from {{ ref('stg_salesorderdetail') }}
)

-- CTE: final
-- Joins header and detail, then generates surrogate keys for important dimensions
, final as (
    select
        {{ dbt_utils.surrogate_key(['salesorderdetail.salesorderid']) }} as sales_key,            -- Order ID surrogate key
        {{ dbt_utils.surrogate_key(['productid']) }} as product_key,                              -- Product surrogate key
        {{ dbt_utils.surrogate_key(['orderdate']) }} as order_date_key,                           -- Order date surrogate key
        {{ dbt_utils.surrogate_key(['customerid']) }} as customer_key,                            -- Customer surrogate key
        salesorderdetail.salesorderdetailid,                                                      -- Detail-level natural key
        salesorderdetail.unitprice,
        salesorderdetail.orderqty,
        salesorderdetail.qty_price                                                               
    from salesorderdetail
    left join salesorderheader
        on salesorderdetail.salesorderid = salesorderheader.salesorderid
)

-- Final output
select *
from final

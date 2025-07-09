-- Sales dimension model
-- This model joins sales order headers and details to produce a clean, enriched dataset
-- with a surrogate key for each sales line, ready for use in fact tables or reporting

-- Step 1: Get relevant fields from the sales order header (customer-level metadata)
with salesorderheader as (
    select
        salesorderid,
        customerid,
        creditcardid,
        shiptoaddressid,
        order_status,
        date(stg_salesorderheader.orderdate) as orderdate  -- Truncate to date only
    from {{ ref('stg_salesorderheader') }}
),

-- Step 2: Get relevant fields from the sales order detail (line-level transactions)
salesorderdetail as (
    select
        salesorderid,
        salesorderdetailid,
        productid,
        orderqty,
        unitprice
    from {{ ref('stg_salesorderdetail') }}
),

-- Step 3: Join detail with header and generate a surrogate key per sales line
final as (
    select
        {{ dbt_utils.surrogate_key(['sod.salesorderid', 'sod.salesorderdetailid']) }} as sales_id_key,  -- Unique ID per sales line
        soh.customerid,
        soh.creditcardid,
        soh.shiptoaddressid,
        soh.order_status,
        soh.orderdate,
        sod.productid
    from salesorderdetail as sod
    left join salesorderheader as soh
        on sod.salesorderid = soh.salesorderid
)

-- Step 4: Return final sales fact table
select * 
from final

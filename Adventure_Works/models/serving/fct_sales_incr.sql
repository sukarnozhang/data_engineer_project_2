-- DBT model: Incremental loading of sales data with surrogate keys
-- Materialization: Incremental
-- Unique key: modifieddate
-- Behavior on schema change: Fail if schema changes unexpectedly

{{
    config(
        materialized = 'incremental',       -- Only new/changed rows will be added on each run
        unique_key = 'modifieddate',        -- Used to identify new/updated records
        on_schema_change = 'fail'           -- Fail the run if schema changes (for strict data governance)
    )
}}

-- CTE: Load and prepare sales order header data
with salesorderheader as (
    select
        salesorderid,
        customerid,
        creditcardid,
        shiptoaddressid,
        order_status,
        modifieddate,                               -- Used for incremental filtering
        date(stg_salesorderheader.orderdate) as orderdate
    from {{ ref('stg_salesorderheader') }}
)

-- CTE: Load and prepare sales order detail data
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

-- CTE: Join header and detail tables; generate surrogate keys for dimension keys
, final as (
    select
        {{ dbt_utils.surrogate_key(['salesorderdetail.salesorderid']) }} as sales_key,         -- Sales order surrogate key
        {{ dbt_utils.surrogate_key(['productid']) }} as product_key,                            -- Product surrogate key
        {{ dbt_utils.surrogate_key(['customerid']) }} as customer_key,                          -- Customer surrogate key
        {{ dbt_utils.surrogate_key(['orderdate']) }} as order_date_key,                         -- Order date surrogate key

        salesorderdetail.salesorderdetailid,
        salesorderdetail.unitprice,
        salesorderdetail.orderqty,
        salesorderdetail.qty_price,
        salesorderheader.modifieddate                                                      -- For incremental comparison
    from salesorderdetail
    left join salesorderheader 
        on salesorderdetail.salesorderid = salesorderheader.salesorderid
)

-- Final SELECT: Return the enriched, joined data
select *
from final

-- Incremental condition: only select records with newer modifieddate than what already exists
{% if is_incremental() %}
    where modifieddate > (select max(modifieddate) from {{ this }})
{% endif %}

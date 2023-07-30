{{
    config(
        materialized='incremental',
        unique_key='modifieddate',
        on_schema_change='fail'
    )
}}

with salesorderheader as (
    select
        salesorderid,
        customerid,
        creditcardid,
        shiptoaddressid,
        order_status,
        modifieddate,
        date(stg_salesorderheader.orderdate) as orderdate
    from {{ ref('stg_salesorderheader') }}
)

, salesorderdetail as (
    select
        salesorderid,
        salesorderdetailid,
        productid,
        orderqty,
        unitprice,
        unitprice * orderqty as qty_price
    from {{ ref('stg_salesorderdetail')}}
)
, final as (
    select
        {{ dbt_utils.surrogate_key(['salesorderdetail.salesorderid'])}} sales_key
        , {{ dbt_utils.surrogate_key(['productid'])}} as product_key
        ,{{ dbt_utils.surrogate_key(['customerid']) }} as customer_key 
        , {{ dbt_utils.surrogate_key(['creditcardid']) }} as creditcard_key
        , {{ dbt_utils.surrogate_key(['shiptoaddressid']) }} as ship_address_key
        , {{ dbt_utils.surrogate_key(['order_status']) }} as order_status_key
        , {{ dbt_utils.surrogate_key(['orderdate']) }} as order_date_key
        , salesorderdetail.salesorderdetailid
        , salesorderdetail.unitprice
        , salesorderdetail.orderqty
        , salesorderdetail.qty_price
        , salesorderheader.modifieddate
    from salesorderdetail
    left join salesorderheader on salesorderdetail.salesorderid = salesorderheader.salesorderid
)
select *
from final

{% if is_incremental() %}
    where modifieddate > (select max(modifieddate) from {{ this }})
{% endif %}

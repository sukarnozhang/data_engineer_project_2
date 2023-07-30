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

, salesorderdetail as (
    select
        salesorderid,
        salesorderdetailid,
        productid,
        orderqty,
        unitprice
    from {{ ref('stg_salesorderdetail')}}
)
, final as (
    select
        {{ dbt_utils.surrogate_key(['salesorderdetail.salesorderid','salesorderdetailid'])}} sales_id_key
        , salesorderheader.customerid
        , salesorderheader.creditcardid
        , salesorderheader.shiptoaddressid
        , salesorderheader.order_status
        , salesorderheader.orderdate
        , salesorderdetail.productid
    from salesorderdetail
    left join salesorderheader on salesorderdetail.salesorderid = salesorderheader.salesorderid
)
select *
from final

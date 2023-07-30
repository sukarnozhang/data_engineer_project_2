with salesorderheader as (
    select
        salesorderid
        , customerid
        , creditcardid
        , shiptoaddressid
        , order_status
        , date(stg_salesorderheader.orderdate) orderdate
    from {{ ref('stg_salesorderheader') }} 
)

, salesorderdetail as (
    select
        salesorderid
        , salesorderdetailid
        , productid
        , orderqty
        , unitprice
        , unitprice * orderqty  as  revenue_wo_taxandfreight
        , modifieddate
    from {{ref('stg_salesorderdetail')}}
)

, snp_product as ( 
    select *
    from {{ ref('snp_product') }}
)

, salesorderdetail_product as (
    select 
        row_number() over (partition by salesorderdetail.salesorderdetailid order by salesorderdetail.modifieddate desc) as latest_row
        , salesorderid
        , salesorderdetailid
        , salesorderdetail.productid
        , orderqty
        , unitprice
        , salesorderdetail.modifieddate
        , snp_product.dbt_valid_from as product_valid_from
        , snp_product.dbt_valid_to as product_valid_to
    from salesorderdetail
    left join snp_product on salesorderdetail.productid = snp_product.productid 
        and salesorderdetail.modifieddate between snp_product.dbt_valid_from and coalesce(snp_product.dbt_valid_to, '2999-01-01')
)

/* We then join salesorderdetail and salesorderheader to get the final fact table*/
, final as (
    select
        {{ dbt_utils.surrogate_key(['salesorderdetail_product.salesorderid', 'salesorderdetailid'])  }} sales_key
        , {{ dbt_utils.surrogate_key(['productid', 'product_valid_from', 'product_valid_to']) }} as product_key
        , {{ dbt_utils.surrogate_key(['customerid']) }} as customer_key 
        , {{ dbt_utils.surrogate_key(['creditcardid']) }} as creditcard_key
        , {{ dbt_utils.surrogate_key(['shiptoaddressid']) }} as ship_address_key
        , {{ dbt_utils.surrogate_key(['order_status']) }} as order_status_key
        , {{ dbt_utils.surrogate_key(['orderdate']) }} as order_date_key
        , salesorderdetail_product.productid
        , salesorderdetail_product.modifieddate
        , salesorderdetail_product.product_valid_from
        , salesorderdetail_product.product_valid_to
        , salesorderdetail_product.salesorderid
        , salesorderdetail_product.salesorderdetailid
        , salesorderdetail_product.unitprice
        , salesorderdetail_product.orderqty
    from salesorderdetail_product
    left join salesorderheader on salesorderdetail_product.salesorderid = salesorderheader.salesorderid
    where salesorderdetail_product.latest_row = 1 
)

select *
from final

with source_data as (
    select
        salesorderid
        , orderqty
        , salesorderdetailid
        , unitprice
        , specialofferid
        , modifieddate
        , rowguid
        , productid
        , unitpricediscount
    from {{ source('AIRBYTE_SCHEMA', 'salesorderdetail') }}
)
select *
from source_data
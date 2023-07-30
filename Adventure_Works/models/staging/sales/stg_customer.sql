with source_data as (
    select
        customerid
        , personid
        , storeid
        , territoryid
    from {{ source('AIRBYTE_SCHEMA', 'customer') }}
)
select *
from source_data	
with source_data as (
    select
        creditcardid
        , cardtype
        , expyear
        , modifieddate
        , expmonth
        , cardnumber
    from {{ source('AIRBYTE_SCHEMA', 'creditcard') }}
)
select *
from source_data
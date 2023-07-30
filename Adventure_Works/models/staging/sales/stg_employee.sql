with source_data as (
    select
        businessentityid,
        gender
    from {{ source('AIRBYTE_SCHEMA', 'employee') }}
)
select *
from source_data	
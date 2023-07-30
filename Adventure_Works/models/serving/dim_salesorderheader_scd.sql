with snp_salesorderheader as (
    select
        {{ dbt_utils.surrogate_key(['salesorderid', 'dbt_valid_from', 'dbt_valid_to']) }} as snp_salesorderheader_key 
        , *
    from {{ ref('snp_salesorderheader') }}
) 

select * 
from snp_salesorderheader
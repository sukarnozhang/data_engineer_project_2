with snp_customer as (
    select
        {{ dbt_utils.surrogate_key(['customerid', 'dbt_valid_from', 'dbt_valid_to']) }} as snp_customer_key 
        , personid 
        , territoryid
        , storeid
    from {{ ref('snp_customer') }}
) 

select * 
from snp_customer

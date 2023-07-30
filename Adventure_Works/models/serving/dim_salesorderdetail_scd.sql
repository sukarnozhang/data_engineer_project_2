with snp_salesorderdetail as (
    select
        {{ dbt_utils.surrogate_key(['salesorderdetailid', 'dbt_valid_from', 'dbt_valid_to']) }} as snp_orderdetailid_key 
        , *
    from {{ ref('snp_salesorderdetail') }}
) 

select * 
from snp_salesorderdetail

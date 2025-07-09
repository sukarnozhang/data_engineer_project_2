-- CTE 'snp_salesorderdetail' adds a surrogate key combining 
-- 'salesorderdetailid', 'dbt_valid_from', and 'dbt_valid_to' to uniquely identify each snapshot record.
-- Selects all columns from the referenced snapshot model along with the new surrogate key.
--  for example: changes in quantity, discount

with snp_salesorderdetail as (
    select
        {{ dbt_utils.surrogate_key(['salesorderdetailid', 'dbt_valid_from', 'dbt_valid_to']) }} as snp_orderdetailid_key,  -- Surrogate key for snapshot version
        *                                                                                                                  -- All existing columns from the snapshot
    from {{ ref('snp_salesorderdetail') }}                                                                               -- Reference to the snapshot table/model
)

-- Return all columns including the surrogate key
select * 
from snp_salesorderdetail


-- CTE 'snp_salesorderheader' generates a surrogate key for each snapshot record
-- by hashing 'salesorderid', 'dbt_valid_from', and 'dbt_valid_to' to uniquely identify versions.
-- Selects all columns from the referenced snapshot model along with the surrogate key.
-- For example, changes in status of shipping, shipdate

with snp_salesorderheader as (
    select
        {{ dbt_utils.surrogate_key(['salesorderid', 'dbt_valid_from', 'dbt_valid_to']) }} as snp_salesorderheader_key,  -- Unique surrogate key for each snapshot version
        *                                                                                                                 -- All columns from the snapshot table
    from {{ ref('snp_salesorderheader') }}                                                                              -- Reference to the snapshot model/table
)

-- Return all columns including the surrogate key
select * 
from snp_salesorderheader

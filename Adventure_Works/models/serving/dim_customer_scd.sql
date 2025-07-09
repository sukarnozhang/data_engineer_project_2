-- Create a CTE named 'snp_customer' to generate a surrogate key
-- combining 'customerid', 'dbt_valid_from', and 'dbt_valid_to' to uniquely identify snapshot records.
-- Also selects key business columns: personid, territoryid, and storeid.
--  to track changes in territotyid and storeid for example

with snp_customer as (
    select
        {{ dbt_utils.surrogate_key(['customerid', 'dbt_valid_from', 'dbt_valid_to']) }} as snp_customer_key,  -- Surrogate key for snapshot record
        *
    from {{ ref('snp_customer') }}              -- Reference to the snapshot model/table 'snp_customer'
)

-- Select all columns from the CTE
select * 
from snp_customer

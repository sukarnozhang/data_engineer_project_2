-- Customer dimension model
-- This model generates a surrogate key for each customer from the staging table

-- Step 1: Reference the cleaned customer staging model
with stg_customer as (
    select * 
    from {{ ref('stg_customer') }}
),

-- Step 2: Add a surrogate key for each customer
transformed as (
    select  
        {{ dbt_utils.surrogate_key(['stg_customer.customerid']) }} as customer_key,
        *
    from stg_customer
)

-- Step 3: Return final transformed data
select * 
from transformed

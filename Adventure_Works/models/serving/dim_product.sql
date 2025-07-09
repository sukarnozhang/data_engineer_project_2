-- Product dimension model
-- This model generates a surrogate key for each product record using the staging layer

-- Step 1: Reference the cleaned product staging model
with stg_product as (
    select * 
    from {{ ref('stg_product') }}
),

-- Step 2: Add a surrogate key to each product row for dimensional joins
transformed as (
    select 
        {{ dbt_utils.surrogate_key(['stg_product.productid']) }} as product_key,  -- Unique hash-based product key
        *
    from stg_product
)

-- Step 3: Return final transformed product data with surrogate key
select * 
from transformed

-- Salesperson effectiveness model
-- This model adds a surrogate key to each salesperson record based on customer engagement and gender.
-- Helps provide insights into sales performance segmented by gender and salesperson.

-- Step 1: Reference the staging model that aggregates customers per salesperson and gender
with stg_salesperson_customer_based_on_gender as (
    select * 
    from {{ ref('stg_salesperson_customer_based_on_gender') }}
),

-- Step 2: Add a surrogate business key based on salesperson ID
transformed as (
    select 
        {{ dbt_utils.surrogate_key(['stg_salesperson_customer_based_on_gender.salesid']) }} as business_key,  -- Unique key per salesperson
        *
    from stg_salesperson_customer_based_on_gender
)

-- Step 3: Return the final transformed table with business key
select * 
from transformed

-- Date dimension model
-- This model adds a surrogate key to each date row from the staging layer

-- Step 1: Reference the cleaned date staging model
with stg_date as (
    select * 
    from {{ ref('stg_date') }}
),

-- Step 2: Add a surrogate key for each unique date
transformed as (
    select 
        {{ dbt_utils.surrogate_key(['stg_date.date_day']) }} as date_key,  -- Unique surrogate key for date
        *
    from stg_date
)

-- Step 3: Return final transformed date dimension with surrogate key
select * 
from transformed

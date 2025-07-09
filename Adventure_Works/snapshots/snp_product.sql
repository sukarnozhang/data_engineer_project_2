-- Snapshot: snp_product
-- This snapshot tracks changes to all fields in the `product` table
-- using the 'check' strategy and `productid` as the unique identifier.

{% snapshot snp_product %}

{{
    config(
        target_schema = 'AIRBYTE_SCHEMA',  
        strategy = 'check',                -- Use 'check' strategy to detect changes
        unique_key = 'productid',          -- Primary key for identifying product records
        check_cols = 'all'                 -- Monitor all columns for changes between runs
    )
}}

-- Source query to capture current state of the product table
select * 
from {{ source('AIRBYTE_SCHEMA', 'product') }}

{% endsnapshot %}

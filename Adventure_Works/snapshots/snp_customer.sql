-- Snapshot: snp_customer
-- This snapshot tracks changes to all columns in the `customer` source table
-- using a 'check' strategy and `customerid` as the unique key.

{% snapshot snp_customer %}

{{
    config(
        target_schema = 'AIRBYTE_SCHEMA',
        strategy = 'check',                -- Use 'check' strategy to compare all columns for changes
        unique_key = 'customerid',         -- Unique identifier for tracking changes
        check_cols = 'all'                 -- Monitor all columns for changes between runs
    )
}}

-- Pull the latest customer data from the source system
select * 
from {{ source('AIRBYTE_SCHEMA', 'customer') }}

{% endsnapshot %}

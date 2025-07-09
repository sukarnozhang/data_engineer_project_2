-- Snapshot: snp_salesorderheader
-- Tracks changes in the 'salesorderheader' table using the 'timestamp' strategy.
-- Uses 'salesorderid' as the unique key and 'modifieddate' to detect updates.

{% snapshot snp_salesorderheader %}

{{
    config(
        target_schema = 'AIRBYTE_SCHEMA', 
        strategy = 'timestamp',                -- Detect changes using timestamp column
        unique_key = 'salesorderid',           -- Unique identifier for each record
        updated_at = 'modifieddate'             -- Timestamp column indicating last update
    )
}}

-- Select all columns from the source 'salesorderheader' table
select * 
from {{ source('AIRBYTE_SCHEMA', 'salesorderheader') }}

{% endsnapshot %}

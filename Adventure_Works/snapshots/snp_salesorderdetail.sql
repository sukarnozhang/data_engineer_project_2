-- Snapshot: snp_salesorderdetail
-- This snapshot tracks changes in the 'salesorderdetail' table
-- using the 'timestamp' strategy and 'salesorderdetailid' as the unique identifier.
-- Changes are detected based on the 'modifieddate' timestamp column.

{% snapshot snp_salesorderdetail %}

{{
    config(
        target_schema = 'AIRBYTE_SCHEMA',
        strategy = 'timestamp',                 -- Use 'timestamp' strategy to detect changes
        unique_key = 'salesorderdetailid',     -- Primary key for identifying records uniquely
        updated_at = 'modifieddate'             -- Timestamp column to track record updates
    )
}}

-- Select all columns from the source 'salesorderdetail' table
select * 
from {{ source('AIRBYTE_SCHEMA', 'salesorderdetail') }}

{% endsnapshot %}

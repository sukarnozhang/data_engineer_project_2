{% snapshot snp_salesorderheader %}

{{
    config(
        target_schema='AIRBYTE_SCHEMA',
        strategy='timestamp',
        unique_key='salesorderid',
        updated_at='modifieddate',
    )
}}

select * from {{ source('AIRBYTE_SCHEMA', 'salesorderheader')}}

{% endsnapshot %}
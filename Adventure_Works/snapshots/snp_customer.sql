{% snapshot snp_customer %}

{{
    config(
        target_schema='AIRBYTE_SCHEMA',
        strategy='check',
        unique_key='customerid',
        check_cols='all'
    )
}}

select * from {{ source('AIRBYTE_SCHEMA', 'customer')}}

{% endsnapshot %}
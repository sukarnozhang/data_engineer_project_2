{% snapshot snp_product %}

{{
    config(
        target_schema='AIRBYTE_SCHEMA',
        strategy='check',
        unique_key='productid',
        check_cols='all'
    )
}}

select * from {{ source('AIRBYTE_SCHEMA', 'product')}}

{% endsnapshot %}
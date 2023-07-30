{% snapshot snp_salesorderdetail %}

{{
    config(
        target_schema='AIRBYTE_SCHEMA',
        strategy='timestamp',
        unique_key='salesorderdetailid',
        updated_at='modifieddate',
    )
}}

select * from {{ source('AIRBYTE_SCHEMA', 'salesorderdetail')}}

{% endsnapshot %}
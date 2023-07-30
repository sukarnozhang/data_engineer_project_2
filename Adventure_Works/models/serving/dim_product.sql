with stg_product as (
    select * from {{ ref('stg_product') }}
)
, transformed as (
    select 
        {{ dbt_utils.surrogate_key(['stg_product.productid']) }} as product_key,
        *
    from stg_product
)

select * 
from transformed

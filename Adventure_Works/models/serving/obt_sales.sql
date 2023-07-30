with fct_sales as (
    select * from {{ ref('fct_sales') }}
)
, dim_customers as (
    select * from {{ ref('dim_customer') }}
)
, dim_products as (
    select * from {{ ref('dim_product') }}
)
, dim_date as (
    select * from {{ ref('dim_date') }}
)
, obt as (
    select
         {{ dbt_utils.star(from=ref('fct_sales'), relation_alias='fct_sales', except=[
            "sales_key", "product_key", "customer_key", "creditcard_key", "ship_address_key", "order_status_key", "order_date_key"
            ]) }}
         , {{ dbt_utils.star(from=ref('dim_product'), relation_alias='dim_product', except=["product_key"]) }}
         , {{ dbt_utils.star(from=ref('dim_customer'), relation_alias='dim_customer', except=["customer_key"]) }}
         , {{ dbt_utils.star(from=ref('dim_date'), relation_alias='dim_date', except=["date_key"]) }}
    from fct_sales
    left join dim_product on fct_sales.product_key = dim_product.product_key 
    left join dim_customer on fct_sales.customer_key = dim_customer.customer_key 
    left join dim_date on fct_sales.order_date_key = dim_date.date_key 
)

select * 
from obt
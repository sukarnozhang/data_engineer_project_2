-- Combine the fact_sales table with related dimensions (product, customer, and date)
-- to produce an enriched One Big Table (OBT) for reporting and analytics.

-- CTE: Fact sales table
with fct_sales as (
    select * 
    from {{ ref('fct_sales') }}
)

-- CTE: Product dimension table
, dim_products as (
    select * 
    from {{ ref('dim_product') }}
)

-- CTE: Customer dimension table
, dim_customers as (
    select * 
    from {{ ref('dim_customer') }}
)

-- CTE: Date dimension table
, dim_date as (
    select * 
    from {{ ref('dim_date') }}
)

-- CTE: Join fact with dimensions to create enriched data
, obt as (
    select
        -- Include all columns from fct_sales except keys used for joining
        {{ dbt_utils.star(from=ref('fct_sales'), relation_alias='fct_sales', except=[
            "sales_key", "product_key", "customer_key", "order_date_key"
        ]) }},
        
        -- Include all descriptive fields from product dimension
        {{ dbt_utils.star(from=ref('dim_product'), relation_alias='dim_product', except=["product_key"]) }},

        -- Include all descriptive fields from customer dimension
        {{ dbt_utils.star(from=ref('dim_customer'), relation_alias='dim_customer', except=["customer_key"]) }},

        -- Include all descriptive fields from date dimension
        {{ dbt_utils.star(from=ref('dim_date'), relation_alias='dim_date', except=["date_key"]) }}
    
    from fct_sales

    -- Join with product dimension
    left join dim_product 
        on fct_sales.product_key = dim_product.product_key

    -- Join with customer dimension
    left join dim_customer 
        on fct_sales.customer_key = dim_customer.customer_key

    -- Join with date dimension
    left join dim_date 
        on fct_sales.order_date_key = dim_date.date_key
)

-- Final SELECT: return full enriched table
select * 
from obt

with stg_customer as(
    select * from {{ref('stg_customer')}}
),
transformed as(
    select  {{ dbt_utils.surrogate_key(['stg_customer.customerid']) }} as customer_key,
        *
    from stg_customer
)

select * 
from transformed
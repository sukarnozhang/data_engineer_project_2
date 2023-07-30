--Find effectiveness of each sales person based on count of customers handling by grouping by gender and per salespersonid to provide meaningful insights to boost sales.

with stg_salesperson_customer_based_on_gender as (
    select * from {{ ref('stg_salesperson_customer_based_on_gender') }}
)
,transformed as (
    select 
        {{ dbt_utils.surrogate_key(['stg_salesperson_customer_based_on_gender.salesid']) }} as business_key,
		*
    from stg_salesperson_customer_based_on_gender
)

select * 
from transformed


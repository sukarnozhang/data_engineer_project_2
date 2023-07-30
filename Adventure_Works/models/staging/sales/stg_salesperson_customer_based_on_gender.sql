--Find effectiveness of each sales person based on count of customers handling by grouping by gender and per salespersonid to provide meaningful insights to boost sales.
with source_data as (
    select
        count_of_customers,
		salesid,
		gen
    from {{ ref('salesperson_customer_based_on_gender') }}
)
select *
from source_data

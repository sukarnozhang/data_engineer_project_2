--Insights into the type of currency , average rate for purchase done by customers.
with currency_rate as(
    select tocurrencycode,
    fromcurrencycode,
    currencyrateid,
    averagerate
    from {{ source("AIRBYTE_SCHEMA","currencyrate") }}
),

sales_order_header as(
    select currencyrateid,
    customerid
    from {{ source("AIRBYTE_SCHEMA","salesorderheader") }}
)

select
    c.tocurrencycode,
    c.fromcurrencycode,
    c.currencyrateid,
    c.averagerate,
    s.customerid
from sales_order_header as s
    inner join currency_rate as c
    on s.currencyrateid = c.currencyrateid




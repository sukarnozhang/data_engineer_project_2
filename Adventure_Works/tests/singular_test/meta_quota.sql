--Singular test based average currency rate greater than 10 with severity "error".

{{
    config(
        severity = 'error'
    )
}}
with currency_rate as(
    select tocurrencycode,
    fromcurrencycode,
    currencyrateid,
    averagerate
    from currencyrate
),

sales_order_header as(
    select currencyrateid,
    customerid
    from salesorderheader
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
where
    c.averagerate > 10



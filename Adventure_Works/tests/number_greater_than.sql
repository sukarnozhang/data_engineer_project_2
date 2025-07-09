{% test number_greater_than(model, column_name, min_num) %}

    select *
    from {{ model }}
    where {{ column_name }} < {{ min_num }}

{% endtest %}


--Macro function to allocate commission to salesperson based on count of products they have sold.
{% macro salesperson_commission(count_of_product,commission) %}
    case
            when {{ count_of_product }} = 1000 then {{ commission }} * 1.75
            when {{ count_of_product }} = 500 then {{ commission }} * 1.25
            else {{ commission }}
        end
{% endmacro %}

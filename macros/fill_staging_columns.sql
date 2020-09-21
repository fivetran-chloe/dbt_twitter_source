{% macro fill_staging_columns(source_columns, staging_columns) -%}

{%- set source_column_names = source_columns|map(attribute='name')|map('lower')|list -%}

{%- for column in staging_columns %}
    {% if column.name|lower in source_column_names -%}
        {{ column.name }}
        {%- if 'alias' in column %} as {{ column.alias }} {%- endif -%}
    {%- else -%}
        cast(null as {{ column.datatype }})
        {%- if 'alias' in column %} as {{ column.alias }} {% else %} {{ column.name }} {% endif -%}
    {%- endif -%}
    {%- if not loop.last -%} , {% endif -%}
{% endfor %}

{% endmacro %} 
{% macro generate_columns_from_db(table_name, schema_name, project_name=target.database) %}

{% set query %}

select
    concat(
      '{"name": "', 
      lower(column_name), 
      '", "datatype": ',
      case
        when lower(data_type) like '%timestamp%' then 'dbt_utils.type_timestamp()' 
        when lower(data_type) = 'string' then 'dbt_utils.type_string()' 
        when lower(data_type) = 'bool' then '"boolean"'
        when lower(data_type) = 'numeric' then 'dbt_utils.type_numeric()' 
        when lower(data_type) = 'float64' then 'dbt_utils.type_float()' 
        when lower(data_type) = 'int64' then 'dbt_utils.type_int()' 
        when lower(data_type) = 'date' then '"date"' 
        when lower(data_type) = 'datetime' then '"datetime"' 
      end,
      '}')
from `{{ project_name }}`.{{ schema_name }}.INFORMATION_SCHEMA.COLUMNS
where lower(table_name) = '{{ table_name }}'
and lower(table_schema) = '{{ schema_name }}'
order by 1

{% endset %}

{% set results = run_query(query) %}
{% set results_list = results.columns[0].values() %}

{% set jinja_macro=[] %}

{% do jinja_macro.append('{% macro get_' ~ table_name ~ '_columns() %}') %}
{% do jinja_macro.append('') %}
{% do jinja_macro.append('{% set columns = [') %}

{% for result in results_list %}
{% do jinja_macro.append('    ' ~ result ~ (',' if not loop.last)) %}
{% endfor %}

{% do jinja_macro.append('] %}') %}
{% do jinja_macro.append('') %}
{% do jinja_macro.append('{{ return(columns) }}') %}
{% do jinja_macro.append('') %}
{% do jinja_macro.append('{% endmacro %}') %}

{% if execute %}

    {% set joined = jinja_macro | join ('\n') %}
    {{ log(joined, info=True) }}
    {% do return(joined) %}

{% endif %}

{% endmacro %}
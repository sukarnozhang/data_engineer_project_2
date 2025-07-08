--generates a table of dates from January 1, 2011 to the date the current dbt run started.
{{ dbt_date.get_date_dimension("2011-01-01", run_started_at.strftime("%Y-%m-%d")) }}

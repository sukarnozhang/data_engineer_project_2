FROM ghcr.io/dbt-labs/dbt-snowflake:1.2.0

COPY Adventure_Works/ .

COPY docker/run_commands.sh .

ENTRYPOINT ["/bin/bash", "run_commands.sh"]


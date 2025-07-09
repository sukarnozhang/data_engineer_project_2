# Adventure Works ELT Pipeline using AWS, Airbyte, Snowflake and Dbt
The project aims to deploy the Adventure Works public dataset using Airbyte integration into Snowflake, and to develop a Data Build Tool (dbt) for transforming the tables and performing dimensional modeling. This enables better insights into the Adventure Works dataset through the Extract, Load, and Transform (ELT) process.

<img width="1044" alt="Screenshot 2024-05-28 at 10 26 29" src="https://github.com/sukarnozhang/data_engineer_project_2/assets/78150905/317af6a0-0f61-4a48-9e39-37f938f98895">

# Workflow

Extraction of datasets
The datasets are extracted from Adventure Works ("https://github.com/Data-Engineer-Camp/2023-01-bootcamp/blob/main/09-project-2/adventure_works").

1. Data Ingestion:
Airbyte is used as the data integration tool to connect to the AWS RDS as the source.
The source connection in Airbyte is established using the AWS RDS endpoint. The RDS instance hosts a PostgreSQL database, which has been restored locally.

For the destination, Airbyte is configured to deliver the source dataset to Snowflake by running appropriate commands to access and load data into Snowflake.

## Setup Steps
1. Create an RDS Postgres DB to host the Adventure Works DB: https://github.com/Data-Engineer-Camp/2023-01-bootcamp/tree/main/09-project-2/adventure_works
2. Set up Airbyte-specific entities in Snowflake
```sql
-- Set configuration variables (use uppercase for consistency)
set airbyte_role = 'AIRBYTE_ROLE';
set airbyte_username = 'AIRBYTE_USER';
set airbyte_warehouse = 'AIRBYTE_WAREHOUSE';
set airbyte_database = 'AIRBYTE_DATABASE';
set airbyte_schema = 'AIRBYTE_SCHEMA';
set airbyte_password = 'password';

begin;

-- Step 1: Create the Airbyte role
-- The SECURITYADMIN role is required because it's the designated high-level role responsible for managing users and roles securely in Snowflake.
use role securityadmin;
create role if not exists identifier($airbyte_role);

-- Grant the Airbyte role to SYSADMIN for further setup
-- Only the SYSADMIN role has sufficient permissions to create compute resources like warehouses.
grant role identifier($airbyte_role) to role SYSADMIN;

-- Step 2: Create the Airbyte user with the assigned role and default warehouse
create user if not exists identifier($airbyte_username)
  password = $airbyte_password
  default_role = $airbyte_role
  default_warehouse = $airbyte_warehouse;

-- Grant the Airbyte role to the Airbyte user
-- In Snowflake, users don't have privileges directly — they inherit them through roles.
grant role identifier($airbyte_role) to user identifier($airbyte_username);

-- Step 3: Switch to SYSADMIN role to create warehouse and database
use role sysadmin;

-- Create the Airbyte warehouse (small, suspended by default)
create warehouse if not exists identifier($airbyte_warehouse)
  warehouse_size = xsmall
  warehouse_type = standard    -- use snowpark-optimized got compute-heavy loads
  auto_suspend = 60            --  Automatically suspends the warehouse after 60 seconds of inactivity.
  auto_resume = true            -- When Airbyte sends data, the warehouse automatically restarts if it's suspended.
  initially_suspended = true;  -- When the warehouse is created, it starts in a suspended (paused) state

-- Create the Airbyte database
create database if not exists identifier($airbyte_database);

-- Grant access to the Airbyte warehouse
grant usage
  on warehouse identifier($airbyte_warehouse)
  to role identifier($airbyte_role);

-- Grant ownership of the Airbyte database to the Airbyte role
grant ownership
  on database identifier($airbyte_database)
  to role identifier($airbyte_role);

commit;

begin;

-- Step 4: Create schema for Airbyte data
use database identifier($airbyte_database);
create schema if not exists identifier($airbyte_schema);

commit;

begin;

-- Step 5: Grant ownership of the schema to the Airbyte role
grant ownership
  on schema identifier($airbyte_schema)
  to role identifier($airbyte_role);

commit;

```
2. Data Transformation
The datasets are extracted and loaded into Snowflake. The Adventure Works datasets are stored in Snowflake under the AIRBYTE_DATABASE database and the AIRBYTE_SCHEMA schema, with all relevant tables ingested through Airbyte.

##Data Build Tool(DBT):
The datasets loaded into Snowflake are connected to the dbt working environment by updating the profiles.yml configuration file.

## Steps:
For connection with editor.
Update the profiles.yml file in the dbt with credentials.
airbyte_snowflake:
  outputs:
    dev:
      type: snowflake
      threads: 1
      account:{{Snowflake user account specification}}
      user: AIRBYTE_USER
      password: password
      role: AIRBYTE_ROLE
      warehouse: AIRBYTE_WAREHOUSE
      database: AIRBYTE_DATABASE
      schema: AIRBYTE_SCHEMA
  target: dev

  -- RUN the "dbt deps" command to initiate connection with Snowflake.

  For transformtion process, the aim of the project to get better insights into sales, customer, product and employee table.
  The different transformations applied on the tables and join together to get better quality data.


## Incremental Model and Full Refresh
"Salesorderheader" table is specified with Incremental configuration through "modifieddate" column and "salesorderid" as unique key through deduped+history.
Other tables are Full Referesh in nature through each run.

## Data Modelling
In the data modelling technique, source , staging and serving are defined.According, the business context and data dimesion, dimesions and facts tables are defined in the serving folder along with yml documentation by use of surrogate key and natural key. The dimension and facts tables are joined finally to get better knowledge of the sales, customer, product, and employee.

## One big table

One big table is constructed by joining different tables through "db_utils.star" to join the tables.

## DBT Snapshot 
The snapshots tables are created for predefined table through "check" function on all columns and through "timestamp" to check a particular column based on "modified date".

## Slow Changing Dimesion
Dimesion tables are created based on snapshot definition to capture changes occuring through addition of surrogate key as "dbt_valid_to" and "dbt_valid_from".

## DBT tests

Singular and Generic both tests are performed along with built in functions for tests as Null and Unique.


## DockerFile
To deploy work on the cloud platform, Docker File is defined outside the Dbt folder as:
FROM ghcr.io/dbt-labs/dbt-snowflake:1.2.0

COPY AIRBYTE_SNOWFLAKE/ .

COPY docker/run_commands.sh .

ENTRYPOINT ["/bin/bash", "run_commands.sh"]

## Secrets configuration
.env file is defined to hold the secret credential.

## Deployment on Cloud Platform
1. create and upload env file to s3
2. add the `profiles.yml` file to the dbt project
3. create a folder named `docker` at the same level as `airbyte_snowfalke` to house `dockerfile` and `run_commands.sh`
4. create and push image
5. create task execution role, [add inline policy to access s3](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/taskdef-envfiles.html)
6. create an ec2 task (remember to set environment file and cloudwatch logs)


## Semantic Analysis through Preset
One big table created is uploaded to Preset through Connection between Snowflake and Preset.io.
The dataset is created and different dashboards are generated to get better analysis.


# SQL Server Pipeline

This directory contains the SQL Server implementation of the customer data engineering pipeline.

The scripts are organized in execution/development order so that the evolution of the pipeline can be followed from source-data exploration through incremental processing, logging, security, execution, and extraction for Spark.

## Script Overview

| #  | Script                                    | Purpose                                                                   |
| -- | ----------------------------------------- | ------------------------------------------------------------------------- |
| 01 | `01_Exploration.sql`                      | Explores and investigates the source customer data.                       |
| 02 | `02_create_data_platform.sql`             | Creates the database objects, schemas, and core data platform structures. |
| 03 | `03_batch_ingestion.sql`                  | Implements the initial batch ingestion of customer data.                  |
| 04 | `04_incremental_load.sql`                 | Implements the first version of incremental customer processing.          |
| 05 | `05_incremental_load_clean.sql`           | Refines and cleans the incremental loading logic.                         |
| 06 | `06_pipeline_logging.sql`                 | Creates and implements pipeline execution logging.                        |
| 07 | `07_customer_incremental_procedure.sql`   | Encapsulates incremental customer processing in a stored procedure.       |
| 08 | `08_Authentication_and_Authorization.sql` | Configures database authentication and authorization.                     |
| 09 | `09_Execution.sql`                        | Executes and validates the pipeline.                                      |
| 10 | `10_Data_Extraction_for_Spark.sql`        | Extracts the active customer dataset for downstream PySpark processing.   |

## Pipeline Flow

```text
Source Data
    ↓
Exploration
    ↓
Data Platform Setup
    ↓
Batch Ingestion
    ↓
Incremental Processing
    ↓
Change Detection
    ↓
Insert / Update / Soft Delete
    ↓
Pipeline Logging
    ↓
Validation
    ↓
Active Customer Dataset
    ↓
PySpark
```

## Key SQL Engineering Concepts

The SQL implementation demonstrates:

* Batch ingestion
* Incremental ETL
* SHA-256 hash-based change detection
* Insert/update processing
* Soft deletes
* Transactions
* `TRY/CATCH` error handling
* Pipeline execution logging
* Stored procedures
* Data-quality validation
* Authentication and authorization
* Source-to-target reconciliation

## Execution Order

The numbered filenames provide a logical progression through the project.

Some scripts are intended to demonstrate individual development stages or concepts rather than represent a single script that must always be executed from beginning to end.

For the complete explanation of the implementation, results, and validation evidence, see the project report in the `docs` directory.

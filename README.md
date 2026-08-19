# Customer Data Engineering Pipeline

**End-to-end customer data engineering project demonstrating incremental ETL, data quality, pipeline logging, SQL Server engineering, and PySpark analytical processing.**

**Author:** Ramil Khalilli
**Repository:** `customer-data-engineering-pipeline`

---

## Project Overview

This project implements an end-to-end customer data engineering pipeline using **Microsoft SQL Server and PySpark**.

The project was designed to demonstrate how raw customer data can be transformed into a reliable, validated, and analytics-ready dataset through a combination of:

* SQL Server data platform development
* Batch ingestion
* Incremental ETL
* SHA-256 hash-based change detection
* Insert/update/soft-delete processing
* Pipeline execution logging
* Transactions and rollback handling
* Error handling
* Data-quality validation
* PySpark DataFrame processing
* Parquet storage
* Partitioning
* Partition pruning
* Analytical aggregation

The project intentionally runs locally rather than relying on paid cloud infrastructure. This allowed the focus to remain on **core data engineering principles and implementation** while still demonstrating Spark capabilities.

---

# Architecture

```text
                         SOURCE DATA
                             │
                             ▼
                    SQL Server Customers
                             │
                             ▼
                    Batch / Incremental ETL
                             │
              ┌──────────────┼──────────────┐
              │              │              │
           INSERT          UPDATE       SOFT DELETE
              │              │              │
              └──────────────┼──────────────┘
                             ▼
                  staging.Customers
                             │
                    is_deleted = 0
                             │
                             ▼
                   customers_active.csv
                             │
                             ▼
                         PySpark
                             │
             ┌───────────────┼───────────────┐
             │               │               │
         Transformations  Aggregations   Segmentation
             │               │               │
             └───────────────┼───────────────┘
                             ▼
                          Parquet
                             │
                  Country Partitioning
                             │
                             ▼
                    Partition Pruning
                             │
                             ▼
                 Analytical Data Products
```

---

# Key Engineering Concepts Demonstrated

## 1. Incremental ETL

Instead of replacing the entire target dataset on every execution, the pipeline determines which records are:

* New
* Changed
* Deleted
* Unchanged

A SHA-256 hash is generated from relevant customer attributes and used to detect changes between the source and staging layers.

This allows the pipeline to update only the records that require processing.

---

## 2. Soft Deletes

Customers that disappear from the source are not physically removed from the staging table.

Instead:

```text
is_deleted = 1
```

is applied.

This preserves the record while allowing downstream processes to distinguish active and deleted customers.

---

## 3. Pipeline Logging

Pipeline executions are recorded in a dedicated logging table.

The log captures information including:

* Run ID
* Pipeline name
* Start time
* End time
* Status
* Inserted rows
* Updated rows
* Deleted rows
* Error message

This provides basic pipeline observability and an execution history.

---

## 4. Transactions and Error Handling

The incremental ETL process uses SQL Server transactions together with `TRY/CATCH` error handling.

Successful executions are committed.

If an error occurs, the transaction can be rolled back and the failure is recorded in the pipeline log.

This helps prevent partially completed ETL operations from leaving the staging layer in an inconsistent state.

---

## 5. Data Quality Validation

The project includes validation checks covering:

* Total records
* Active records
* Deleted records
* Duplicate CustomerIDs
* Source-to-target reconciliation
* Active records missing from the source
* Source records missing from the target
* Final Spark customer-count reconciliation

The final PySpark analytical population reconciles to **18,484 active customers**.

---

# PySpark Processing

The active customer dataset extracted from SQL Server is processed using **PySpark 4.0.4**.

Spark runs locally using:

```text
Master: local[*]
Application: CustomerDataEngineeringProject
```

The Spark component demonstrates:

* SparkSession
* Spark DataFrames
* Schema inspection
* Column transformations
* Filtering
* Aggregation
* Grouping
* Income segmentation
* Lazy evaluation
* Physical execution plans
* Parquet storage
* Partitioning
* Partition pruning

---

# Analytical Results

The active customer dataset contains:

**18,484 customers**

## Customer Distribution by Country

| Country        | Customer Count | Average Yearly Income |
| -------------- | -------------: | --------------------: |
| United States  |          7,819 |            $63,616.83 |
| Australia      |          3,591 |            $64,338.62 |
| United Kingdom |          1,913 |            $52,169.37 |
| France         |          1,810 |            $35,762.43 |
| Germany        |          1,780 |            $42,943.82 |
| Canada         |          1,571 |            $57,167.41 |

The United States contains the largest customer population in the dataset, while Australia has the highest average yearly income among these countries.

---

## Income Segmentation

Customers were divided into two analytical segments based on yearly income.

| Income Segment  | Customer Count | Average Yearly Income |
| --------------- | -------------: | --------------------: |
| Standard Income |         16,286 |            $48,757.83 |
| High Income     |          2,198 |           $120,641.49 |

The segmentation demonstrates how PySpark can be used to derive analytical attributes from operational customer data.

---

# Parquet and Partitioning

The customer dataset is converted from CSV to **Parquet** for analytical processing.

A customer-level Parquet dataset is also partitioned by:

```text
Country
```

This produces a structure similar to:

```text
customers_by_country/
├── Country=Australia/
├── Country=Canada/
├── Country=France/
├── Country=Germany/
├── Country=United Kingdom/
└── Country=United States/
```

Partitioning is used at the customer-data level because each country contains many customer records.

The project also demonstrates the difference between:

```text
groupBy("Country")
```

and:

```text
partitionBy("Country")
```

`groupBy()` performs an analytical aggregation.

`partitionBy()` controls the physical organization of stored data.

---

# Partition Pruning

The partitioned dataset was queried using a country filter:

```text
Country = Australia
```

The Spark physical plan showed:

```text
PartitionFilters:
(isnotnull(Country), Country = Australia)
```

This demonstrates **partition pruning**.

Rather than treating the entire partitioned dataset as one undifferentiated collection of files, Spark can use the partition information to restrict the scan to the relevant country partition.

This provides practical evidence of how physical data layout can influence analytical query processing.

---

# SQL Scripts

The SQL implementation is organized into ten scripts representing the progression of the data engineering pipeline.

| Script                                    | Purpose                                              |
| ----------------------------------------- | ---------------------------------------------------- |
| `01_Exploration.sql`                      | Source data exploration and investigation            |
| `02_create_data_platform.sql`             | Database and schema/platform setup                   |
| `03_batch_ingestion.sql`                  | Initial batch ingestion                              |
| `04_incremental_load.sql`                 | Initial incremental ETL implementation               |
| `05_incremental_load_clean.sql`           | Cleaned/refined incremental implementation           |
| `06_pipeline_logging.sql`                 | Pipeline execution logging                           |
| `07_customer_incremental_procedure.sql`   | Stored procedure for incremental customer processing |
| `08_Authentication_and_Authorization.sql` | Database security and access configuration           |
| `09_Execution.sql`                        | Pipeline execution and testing                       |
| `10_Data_Extraction_for_Spark.sql`        | Extraction of active customer data for PySpark       |

The scripts are intentionally separated so that the development process and evolution of the pipeline can be followed.

---

# Repository Structure

```text
customer-data-engineering-pipeline/
│
├── data/
│   ├── README.md
│   ├── raw_source_customers_table.csv
│   └── customers_active.csv
│
├── docs/
│   ├── README.md
│   └── Customer_Data_Engineering_Pipeline_Report.pdf
│
├── pyspark/
│   ├── README.md
│   └── 11_PySpark_Customer_Analytics.ipynb
│
├── sql/
│   ├── README.md
│   ├── 01_Exploration.sql
│   ├── 02_create_data_platform.sql
│   ├── 03_batch_ingestion.sql
│   ├── 04_incremental_load.sql
│   ├── 05_incremental_load_clean.sql
│   ├── 06_pipeline_logging.sql
│   ├── 07_customer_incremental_procedure.sql
│   ├── 08_Authentication_and_Authorization.sql
│   ├── 09_Execution.sql
│   └── 10_Data_Extraction_for_Spark.sql
│
└── README.md
```

---

# Technology Stack

| Technology                   | Role                                       |
| ---------------------------- | ------------------------------------------ |
| Microsoft SQL Server 2022    | Relational data platform and ETL           |
| T-SQL                        | Data engineering and pipeline logic        |
| SQL Server Management Studio | SQL development and administration         |
| Python                       | PySpark environment                        |
| PySpark 4.0.4                | Analytical processing                      |
| Google Colab                 | Local Spark development environment        |
| CSV                          | Data transfer between SQL Server and Spark |
| Parquet                      | Analytical storage                         |
| GitHub                       | Version control and project documentation  |

---

# Key Results

The completed project demonstrates a working pipeline from source data to analytical output.

### SQL Server

* Incremental customer processing implemented
* New records detected and inserted
* Changed records detected using SHA-256 hashes
* Deleted source records handled through soft deletes
* Pipeline executions logged
* Errors captured
* Transactions and rollback handling implemented
* Data-quality checks performed

### PySpark

* 18,484 active customers successfully processed
* Customer schema validated
* Country-level analytical metrics generated
* Income segmentation implemented
* Data converted to Parquet
* Customer data partitioned by country
* Partition pruning demonstrated through Spark's physical execution plan
* Final customer population reconciled with SQL Server

---

# What I Learned

This project strengthened my understanding of several core data engineering concepts.

### Incremental processing

A production-oriented pipeline should not unnecessarily reload and process unchanged records. Change detection and incremental processing can reduce unnecessary work and make pipelines more scalable.

### Data reliability

ETL logic needs transactions, error handling, validation and logging—not simply successful SQL execution.

### Observability

Pipeline logs provide evidence of what happened during each execution and make troubleshooting significantly easier.

### Data quality

A pipeline should validate its outputs. Reconciliation between upstream and downstream datasets is an important part of ensuring correctness.

### Spark architecture

PySpark introduced a different processing model based on DataFrames, lazy evaluation, transformations, actions and execution planning.

### Physical data organization

Partitioning is a storage decision, while grouping is an analytical operation. Understanding this distinction helped demonstrate why partition pruning can improve selective reads.

### Debugging

Several issues encountered during development—including temporary-table collisions, variable-scope problems, CSV header handling and Python/Spark function conflicts—provided practical experience in diagnosing and correcting data pipeline failures.

---

# Project Documentation

A comprehensive project report is available in:

[`docs/Customer_Data_Engineering_Pipeline_Report.pdf`](docs/Customer_Data_Engineering_Pipeline_Report.pdf)

The report contains detailed explanations of:

* Project objectives
* Architecture
* SQL Server implementation
* Incremental ETL
* Pipeline logging
* Error handling
* Data-quality validation
* PySpark processing
* Parquet storage
* Partitioning
* Partition pruning
* Results
* Technical challenges
* Learning outcomes
* Supporting evidence and screenshots

---

# Author

**Ramil Khalilli**

This project was independently designed and implemented as a practical demonstration of data engineering skills across SQL Server and PySpark.

---

# License

This project is licensed under the **MIT License**.

The repository contains synthetic customer data created for educational and demonstration purposes.

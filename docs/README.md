# Project Documentation

This directory contains the supporting documentation for the **Customer Data Engineering Pipeline** project.

## Project Report

### `Customer_Data_Engineering_Pipeline_Report.pdf`

The comprehensive project report documents the complete development process, from the initial source-data exploration through SQL Server ETL and PySpark analytics.

The report covers:

* Project objectives and requirements
* Data architecture
* Source-data exploration
* SQL Server platform design
* Batch ingestion
* Incremental ETL
* Hash-based change detection
* Insert, update, and soft-delete logic
* Pipeline logging
* Transactions and error handling
* Authentication and authorization
* Data-quality validation
* SQL-to-Spark data extraction
* PySpark transformations and analysis
* Parquet storage
* Partitioning
* Partition pruning
* Analytical results
* Technical challenges and debugging
* Lessons learned
* Final outcomes

## Supporting Evidence

The report includes space for screenshots and other evidence demonstrating the implementation and results of the pipeline.

Examples include:

* SQL Server table structures
* Incremental load results
* Pipeline execution logs
* Data-quality validation results
* PySpark DataFrame outputs
* Parquet output
* Spark physical execution plans
* Partition pruning evidence
* Analytical results

These screenshots are intended to provide visual evidence that the documented processes were actually implemented and tested.

## Project Relationship

The overall project can be understood through three main components:

```text
SQL Server
    ↓
Data Engineering Pipeline
    ↓
Active Customer Dataset
    ↓
PySpark
    ↓
Analytical Outputs
```

The SQL implementation is available in the `sql` directory, while the PySpark implementation is available in the `pyspark` directory.

Synthetic datasets used by the project are available in the `data` directory.

## Author

**Ramil Khalilli**

This project was independently designed and implemented as a practical demonstration of data engineering skills across SQL Server and PySpark.

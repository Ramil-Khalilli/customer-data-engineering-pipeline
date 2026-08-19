# PySpark Customer Analytics

This directory contains the PySpark component of the customer data engineering pipeline.

The purpose of this stage is to demonstrate how an analytics-ready customer dataset produced by the SQL Server pipeline can be processed using **Apache Spark**.

The project uses **PySpark 4.0.4** running locally with:

```text
Master: local[*]
Application: CustomerDataEngineeringProject
```

## Notebook

### `02_PySpark_Customer_Analytics.ipynb`

The notebook demonstrates the complete Spark processing workflow, including:

* SparkSession initialization
* Data loading
* Schema inspection
* DataFrame transformations
* Filtering
* Aggregations
* Country-level customer analysis
* Average income calculations
* Income segmentation
* Parquet conversion
* Partitioned data storage
* Partition pruning
* Physical execution-plan inspection
* Final data validation

## Processing Flow

```text
customers_active.csv
        ↓
PySpark DataFrame
        ↓
Schema Validation
        ↓
Data Transformations
        ↓
Analytical Aggregations
        ↓
Income Segmentation
        ↓
Parquet
        ↓
Partition by Country
        ↓
Selective Queries
        ↓
Partition Pruning
```

## Key Results

The Spark pipeline processed **18,484 active customers**.

### Country Analysis

The dataset was aggregated by country to calculate:

* Customer count
* Average yearly income

The largest customer population was from the **United States**, with 7,819 customers.

### Income Segmentation

Customers were divided into:

* **Standard Income:** 16,286 customers
* **High Income:** 2,198 customers

The segmentation was created using yearly income as the business rule.

## Parquet and Partitioning

The customer-level dataset was stored in Parquet format and partitioned by:

```text
Country
```

This creates country-specific partitions that can be used by Spark when executing selective queries.

The project demonstrates the distinction between:

```python
groupBy("Country")
```

and:

```python
partitionBy("Country")
```

`groupBy()` is used for analytical aggregation, while `partitionBy()` controls how data is physically organized when it is written to storage.

## Partition Pruning

A query filtering for a specific country was used to examine Spark's physical execution plan.

The plan included:

```text
PartitionFilters:
(isnotnull(Country), Country = Australia)
```

This provides evidence that Spark recognized the partition column and applied partition pruning when reading the partitioned Parquet dataset.

## Why Local Spark?

The project originally considered using a paid cloud platform, but the final implementation intentionally runs Spark locally.

This keeps the project focused on demonstrating practical Spark knowledge without introducing unnecessary cloud infrastructure costs.

The core Spark concepts demonstrated here are independent of whether Spark runs locally or on a cloud cluster.

## Learning Outcomes

This stage provided practical experience with:

* Spark DataFrames
* Lazy evaluation
* Transformations and actions
* Aggregations
* Parquet
* Data partitioning
* Partition pruning
* Physical execution plans
* Spark-based analytical processing
* Debugging Spark/Python interactions

For the complete project explanation and supporting evidence, see the report in the `docs` directory.

# **Data Ingestion with dlt: NYC Taxi API Example**

## **Introduction to dlt**

`dlt` (Data Load Tool) is an open-source Python library for building **data pipelines**. It simplifies **extracting, transforming, and loading (ETL)** data into various destinations, such as **DuckDB, BigQuery, Redshift**, and others.

This guide walks through setting up a **dlt pipeline** to fetch **NYC Taxi data** from an API, handling pagination, and storing it in **DuckDB** for analysis.

---

## **Installation**

First, install `dlt` with DuckDB as the destination:

```bash
pip install dlt[duckdb]
```

For other destinations, you can install a different bracket, e.g., `bigquery`, `redshift`, etc.

To verify the installation and check the version:

```python
import dlt
print("dlt version:", dlt.__version__)
```

---

## **Fetching NYC Taxi Data using dlt**

We will extract data from the following **API**:

- **Base API URL:**
  ```
  https://us-central1-dlthub-analytics.cloudfunctions.net/data_engineering_zoomcamp_api
  ```
- **Data format:** Paginated JSON (1,000 records per page)
- **Pagination logic:** Stop when an empty page is returned

### **Step 1: Define the API Source**

We define a `dlt` **resource** to handle data extraction and pagination.

```python
import dlt
import requests

BASE_URL = "https://us-central1-dlthub-analytics.cloudfunctions.net/data_engineering_zoomcamp_api"

@dlt.resource(name="nyc_taxi_data", write_disposition="replace")
def fetch_nyc_taxi_data():
    """Fetches NYC Taxi data with automatic pagination."""
    page = 1
    while True:
        response = requests.get(BASE_URL, params={"page": page})
        data = response.json()
        
        if not data:
            break  # Stop if the page is empty
        
        yield data
        page += 1
```

### **Step 2: Run the Pipeline**

We create a `dlt` **pipeline** and run it to extract data and load it into DuckDB.

```python
pipeline = dlt.pipeline(
    pipeline_name="nyc_taxi_pipeline",
    destination="duckdb",
    dataset_name="nyc_taxi_data"
)

# Run the pipeline
load_info = pipeline.run(fetch_nyc_taxi_data())
print(load_info)
```

---

## **Querying Data in DuckDB**

Once the data is loaded, we can connect to the **DuckDB database** and analyze it.

### **Step 3: Connect to DuckDB**

```python
import duckdb
from google.colab import data_table

data_table.enable_dataframe_formatter()

# Connect to the generated DuckDB file
conn = duckdb.connect(f"{pipeline.pipeline_name}.duckdb")

# Set search path to the dataset
conn.sql(f"SET search_path = '{pipeline.dataset_name}'")
```

### **Step 4: Check Available Tables**

```python
conn.sql("SHOW TABLES").df()
```

### **Step 5: Explore the Data**

```python
df = pipeline.dataset(dataset_type="default").nyc_taxi_data.df()
df.head()
```

### **Step 6: Calculate Average Trip Duration**

Run the SQL query to find the **average trip duration in minutes**:

```python
with pipeline.sql_client() as client:
    res = client.execute_sql(
        """
        SELECT
        AVG(date_diff('minute', trip_pickup_date_time, trip_dropoff_date_time))
        FROM nyc_taxi_data;
        """
    )
    print(res)
```

---

## **Summary**

### **What We Achieved:**

✅ Extracted paginated **NYC Taxi data** from an API using `dlt`\
✅ Handled **pagination** automatically\
✅ Loaded data into **DuckDB** for querying\
✅ Executed **SQL queries** to analyze trip duration


# Homework

## **Creating an External Table**
To create an **external table** in BigQuery using Parquet files stored in **Google Cloud Storage (GCS)**, use the following SQL:

```sql
CREATE OR REPLACE EXTERNAL TABLE `your_project.your_dataset.yellow_tripdata_external`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://your_bucket_name/*.parquet']
);
```

### **What is an External Table?**
- An **external table** lets you query data directly from GCS **without loading it into BigQuery storage**.
- This reduces storage costs but may lead to higher query costs since **data is read from GCS each time**.

---

## **Question 1: How many records exist in the 2024 Yellow Taxi Data?**

To find the **total number of records**, run:

```sql
SELECT COUNT(*) FROM your_project.your_dataset.yellow_tripdata_external;
```

To materialize the external table into **a regular BigQuery table** for better performance:

```sql
CREATE OR REPLACE TABLE your_project.your_dataset.yellow_tripdata AS
SELECT * FROM your_project.your_dataset.yellow_tripdata_external;
```

Now, query the materialized table:

```sql
SELECT COUNT(*) FROM your_project.your_dataset.yellow_tripdata;
```

---

## **Question 2: Counting Distinct `PULocationID` and Estimating Data Read**

To count distinct `PULocationID` in both the external and materialized tables:

```sql
SELECT COUNT(DISTINCT PULocationID) FROM your_project.your_dataset.yellow_tripdata_external;
SELECT COUNT(DISTINCT PULocationID) FROM your_project.your_dataset.yellow_tripdata;
```

### **Why are estimated bytes different?**
- **External Table:** `0 MB` is processed because **BigQuery reads only metadata** when running `COUNT(DISTINCT column_name)` on an external table.
- **Materialized Table:** `155.12 MB` is processed because BigQuery **must scan the entire column** in a physically stored table.


---

## **Question 3: Why Do Estimated Bytes Differ When Querying One vs. Two Columns?**

```sql
SELECT PULocationID FROM your_project.your_dataset.yellow_tripdata;
SELECT PULocationID, DOLocationID FROM your_project.your_dataset.yellow_tripdata;
```

### **Why is the estimated data read different?**
BigQuery is a **columnar database**, meaning:
- It **only scans the columns explicitly queried**.
- Querying **one column** (e.g., `PULocationID`) **reads less data** than querying **two columns** (e.g., `PULocationID, DOLocationID`).
- The **more columns you select, the more data BigQuery must scan**, increasing **bytes processed**.


---

## **Question 4: How Many Records Have `fare_amount = 0`?**

```sql
SELECT COUNT(*) FROM your_project.your_dataset.yellow_tripdata WHERE fare_amount = 0;
```

---

## **Question 5: How to Optimize a Table for Frequent Queries?**

If your queries **filter by `tpep_dropoff_datetime` and order by `VendorID`**, **partitioning and clustering** improve efficiency:

```sql
CREATE OR REPLACE TABLE your_project.your_dataset.optimized_yellow_tripdata
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID
AS
SELECT * FROM your_project.your_dataset.yellow_tripdata;
```

### **Why Partition and Cluster?**
- **Partitioning by `tpep_dropoff_datetime`** reduces the amount of data scanned **when filtering by date**.
- **Clustering by `VendorID`** speeds up sorting and grouping operations.

---

## **Question 6: Retrieve Distinct `VendorID` Between Two Dates**

```sql
SELECT DISTINCT VendorID
FROM your_project.your_dataset.yellow_tripdata
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15';
```

### **Comparing Query Performance on Optimized Table**
Querying the **regular table**:

- **Bytes Processed:** `310.24 MB`
- **Slot Milliseconds:** `2501`

Querying the **optimized (partitioned & clustered) table**:

```sql
SELECT DISTINCT VendorID
FROM your_project.your_dataset.optimized_yellow_tripdata
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15';
```

- **Bytes Processed:** `26.84 MB`
- **Bytes Billed:** `27 MB`
- **Slot Milliseconds:** `1679`

### **Why does the optimized table use fewer bytes?**
- The **partitioning** ensures that only relevant date partitions are read.
- The **clustering** makes finding `VendorID` more efficient.

---

## **Question 9: Running `SELECT COUNT(*)` and Estimated Bytes Read**
```sql
SELECT COUNT(*) FROM your_project.your_dataset.yellow_tripdata;
```

### **Why Does `COUNT(*)` Show `0 Bytes Processed`?**
- BigQuery retrieves row counts **from table metadata**, **not by scanning actual data**.
- This means the query **costs nothing** and runs almost **instantly**.

---

## **Key Takeaways**
✅ **External tables** allow querying GCS files but may result in higher query costs.  
✅ **Columnar storage** means querying fewer columns reduces **bytes scanned**.  
✅ **Partitioning & clustering** optimize query performance **by reducing scanned data**.  
✅ **Metadata optimizations** allow `COUNT(*)` to run **without scanning the full table**.  

---


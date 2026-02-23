# Assignment 1 (A1): Distributed Storage + Batch Analytics  
## Durability Trade-offs (Replication vs Erasure Coding) + HDFS + MapReduce + Spark

---

## Overview

In Weeks 1–4 we studied why “big data” requires distributed systems, how distributed storage enables durability and throughput, the **MapReduce** programming model, and why **Apache Spark** became the dominant batch analytics engine.

This assignment gives you hands-on experience with those ideas by:

1. Standing up a **multi-DataNode HDFS environment (3 DataNodes via Docker)**
2. Ingesting real data into HDFS and **measuring replication overhead**
3. Running a **MapReduce-style** aggregation
4. Repeating the analysis in **Apache Spark**
5. Completing a **durability + efficiency mini-study** comparing  
   **replication vs erasure coding**

This assignment intentionally mirrors the trade-offs exposed by real-world
distributed storage systems (e.g., Ceph) **without requiring a multi-node cluster deployment**.

> You may use AI tools for learning and debugging, but your submitted work must
> include direct evidence from your own environment (commands, outputs, results)
> and your report must be written in your own words.

---

## Learning Objectives

By completing this assignment, you will be able to:

- Explain why analytics systems favor **sequential scans** and how storage layout affects performance
- Perform basic **HDFS** operations and reason about **replication overhead**
- Implement a **MapReduce-style** aggregation and explain map → shuffle → reduce
- Implement the same analytics task in **Spark** and explain the developer-experience differences
- Quantify durability trade-offs:
  - **Replication** (simple, fast writes, high storage overhead)
  - **Erasure coding** (storage-efficient, higher compute + write cost)
- Measure and interpret performance differences across systems and configurations

---

## Dataset: POGOH Bike Trips (Tabular Use)

We will use the **POGOH bike trip dataset** (Pittsburgh bike share).  
Later in the semester we will reuse this dataset for **graph analytics**; for A1
we treat it only as a large tabular dataset.

### Getting the data

Use the dataset link on the course site (WPRDC POGOH Trip Data), **or** use the
snapshot provided in the course materials:

- `pogoh_combined_excel_data.xlsx`
- or the equivalent CSV provided in the repo

### Required workflow (sample → full)

During development, create a **small sample** of the data first.  
Run your final jobs on the **full dataset**.

This is standard practice for large-scale analytics workflows.

---

## Environment Options (Pick One)

### Option A: Local Docker Environment

Use the course repository to run Docker Compose for Hadoop + Spark on you computer.

### Option B: Single Cloud VM (AWS / GCP / Azure)

Provision a single VM and install Hadoop + Spark in **pseudo-distributed mode**
(NameNode + DataNode + YARN + Spark on one machine). Recommended to get experience with a cloud provider.

**Minimum suggested VM:**
- 4 vCPUs
- 16 GB RAM
- 50 GB disk

---

# Part 1 — Dataset Exploration + HDFS Setup + Replication Overhead
*(Weeks 1–2 Concepts)*

### Tasks
1. **Explore the dataset locally**
   - Load `pogoh_combined_excel_data.xlsx` with pandas
   - Report: total rows, columns, date range, top 5 start stations
   - Create a sample (10K rows) and save both as CSV:
     ```python
     df_sample = df.sample(n=10000, random_state=42)
     df_sample.to_csv('pogoh_sample.csv', index=False)
     df.to_csv('pogoh_full.csv', index=False)
     ```

2. **Verify Hadoop services are running**
   - Investigate how the set-up is structured (docker-compose.yaml + hadoop.env) to get an understanding of what is going on
   - Show output of `jps` (NameNode, DataNode; include YARN if used)

3. **Create HDFS workspace and upload data**
   - Create directory: `/csc84030/a1/input`
   - Upload both sample and full CSV files
   - Verify with: `hdfs dfs -ls /csc84030/a1/input`
   - Test: `hdfs dfs -cat <file> | head -20`

4. **Measure replication overhead**
   - Record local file size: `ls -lh pogoh_sample.csv`
   - Check HDFS size: `hdfs dfs -du -h <hdfs_path>`
   - Check replication factor: `hdfs dfs -stat %r <hdfs_path>`

5. **Experiment with replication**
   - Set replication to **1**: `hdfs dfs -setrep -w 1 <hdfs_path>`
   - Measure storage: `hdfs dfs -du -h <hdfs_path>`
   - Set replication to **3**: `hdfs dfs -setrep -w 3 <hdfs_path>`
   - Measure storage again
   - Create comparison table:

   | Configuration | File Size | HDFS Size | Overhead |
   |---------------|-----------|-----------|----------|
   | Local         | X MB      | -         | 1.0x     |
   | Rep = 1       | -         | X MB      | 1.0x     |
   | Rep = 3       | -         | 3X MB     | 3.0x     |

### Required evidence

- Dataset exploration output (rows, columns, top stations)
- `jps` output showing Hadoop services
- `hdfs dfs -ls` showing uploaded files
- Storage comparison table with actual measurements
- All commands executed

### Questions to answer

- What does **data locality** mean, and why does it matter?
- Why are **sequential reads** preferred for analytics?
- What does HDFS optimize for vs a traditional database?
- What is the measured storage overhead of replication (from your table)?
- If you had 10TB with rep=3, how much raw storage is needed?

---

# Part 2 — HDFS Replication Study
## Understanding Durability Trade-offs

HDFS uses **replication** to ensure data durability. In this section, you will
explore how replication factors affect storage overhead and fault tolerance.

### A) Configure and test different replication factors

**Task 1: Upload with replication factor = 1**
```bash
hdfs dfs -D dfs.replication=1 -put pogoh_sample.csv /csc84030/a1/rep1/
```

**Task 2: Upload with replication factor = 3**
```bash
hdfs dfs -D dfs.replication=3 -put pogoh_sample.csv /csc84030/a1/rep3/
```

**Task 3: Measure storage overhead**
- Check HDFS web UI (http://localhost:9870) or use:
  ```bash
  hdfs fsck /csc84030/a1/rep1/ -files -blocks -locations
  hdfs fsck /csc84030/a1/rep3/ -files -blocks -locations
  ```
- Record:
  - Original file size
  - Total HDFS space consumed for rep=1
  - Total HDFS space consumed for rep=3
  - Storage overhead ratio: `(total_stored / original_size)`

### B) Experiment: Change replication on existing file

```bash
# Change replication factor of existing file
hdfs dfs -setrep -w 2 /csc84030/a1/rep3/pogoh_sample.csv

# Verify the change
hdfs fsck /csc84030/a1/rep3/pogoh_sample.csv -files -blocks -locations
```

Document what happens to the storage overhead.

### C) Answer these questions

1. **Storage overhead**: With a 100GB file and `dfs.replication=3`, how much
   total storage is consumed? What is the overhead ratio?

2. **Fault tolerance**: If HDFS has `dfs.replication=3`, how many DataNode
   failures can it tolerate before data loss occurs?

3. **Trade-offs**: Why doesn't HDFS use `dfs.replication=10` for all files?
   What are the downsides of higher replication factors?

4. **Real-world scenario**: Your cluster has 10 DataNodes with 1TB each (10TB total).
   With `dfs.replication=3`, what is the maximum usable storage for your data?

---

# Part 3 — MapReduce-Style Aggregation  
*(Week 3 Concepts)*

Run the following aggregation on the **sample**, then the **full dataset**.

### Required aggregations

1. Trips per **start station** (top 20)
2. Trips per **hour of day** (0–23)

### Implementation options (pick one)

#### Option 1 (Recommended): Hadoop Streaming (Python)

- Implement:
  - `mapper.py`
  - `reducer.py`
- Run on HDFS input and write to HDFS output

#### Option 2 (Advanced): Java MapReduce

- Implement Mapper and Reducer in Java
- Build a JAR and run on HDFS input

### Required evidence

- Job submission command
- Output directory listing
- First ~20 lines of output: hdfs dfs -cat <output_path> | head


---

# Part 4 — Spark Batch Analytics  
*(Week 4 Concepts)*

Repeat the same aggregations in **Spark**, reading from HDFS:

1. Trips per start station (top 20)
2. Trips per hour (0–23)

### Requirements

- Use **Spark DataFrames** (preferred) or RDDs
- Submit either:
- a PySpark script (`spark-submit`), or
- a notebook with executed cells

### Performance timing

Record wall-clock runtime for:

- MapReduce-style job
- Spark job

Run each at least **2–3 times** and report the **median**.

### Questions to answer

- Which approach was easier to write? Why?
- What does Spark abstract away compared to MapReduce?

---

## Deliverables

### 1) Code

Submit a zip file or repository link containing:

- MapReduce code (`mapper.py`, `reducer.py` or Java sources)
- Spark code (script or notebook)
- Scripts or commands used for the durability mini-study

### 2) Basic Report (PDF) - Keep this simple / no need to be overly verbose.
"If I had more time, I would have written a shorter letter" ~ Pascal

Your report must include (along with answers to questions above):

1. **Setup**
 - environment choice
 - key setup steps 
   - a high level explaination of the provided set-up
   - additonal steps you took for the set-up
 - proof services are running

2. **HDFS replication measurements**
 - local vs HDFS size
 - replication = 1 vs replication = 3
 - overhead explanation

3. **Durability **
 - Discuss what is replication vs erasure coding?
 - Discuss what you are doing in Part 2

4. **MapReduce results**
 - aggregations
 - timings
 - sample vs full comparison

5. **Spark results**
 - aggregations
 - timings
 - development-experience comparison

6. **Analysis**
 - sequential scans and data locality
 - performance bottlenecks observed
 - impact of durability mechanisms

7. **Conclusion**
 - 5–10 bullet-point summary of lessons learned

---

## Grading (100 points)

- Environment + HDFS ingestion: **15**
- Replication overhead analysis: **10**
- Durability discussion: **10**
- MapReduce correctness: **20**
- Spark correctness: **20**
- Performance analysis: **10**
- Report clarity + evidence: **15**

---

## AI Policy

You may use AI tools for conceptual understanding and debugging.  
Your final submission must be written in your own words and include direct
evidence that you executed the work yourself (commands, outputs, results).

Submissions lacking personalized evidence or appearing largely AI-generated
may be reviewed for academic integrity.

---

## Tips / Pitfalls

- Always develop on the **sample dataset first**
- Sort outputs before selecting “top 20”
- Run performance tests multiple times and report the median
- Keep detailed notes of commands as you work — this is part of the grade

# Assignment 1: HDFS & Distributed Storage

## Overview

This assignment covers:
1. HDFS setup and verification
2. HDFS replication study
3. MapReduce-style aggregation

## Files

- **Assignment1.md** - Complete assignment specification

## Getting Started

### 1. Start the Hadoop cluster

From the cluster dir:
```bash
./start.sh
```

### 2. Verify services are running

```bash
./verify.sh
```

Expected output shows:
- NameNode
- DataNode 1, 2, 3
- ResourceManager
- NodeManager

### 3. Create your HDFS workspace

```bash
docker exec namenode hdfs dfs -mkdir -p /user/<your-netid>/a1/input
docker exec namenode hdfs dfs -mkdir -p /user/<your-netid>/a1/output
```

### 4. Upload data

Place your CSV files in the `data/` directory, then:
```bash
docker exec namenode hdfs dfs -put /data/your-file.csv /user/<your-netid>/a1/input/
```

## Part 2: Replication Study

Test different replication factors:

```bash
# Upload with replication=1
hdfs dfs -D dfs.replication=1 -put sample.csv /user/<netid>/a1/rep1/

# Upload with replication=3
hdfs dfs -D dfs.replication=3 -put sample.csv /user/<netid>/a1/rep3/

# Change replication on existing file
hdfs dfs -setrep -w 3 /user/<netid>/a1/rep3/sample.csv

# Verify replication
hdfs fsck /user/<netid>/a1/rep3/sample.csv -files -blocks -locations
```

## Web UIs

- **HDFS NameNode**: http://localhost:9870
- **YARN ResourceManager**: http://localhost:8088
- **DataNodes**:
  - http://localhost:9864
  - http://localhost:9865
  - http://localhost:9866

## Troubleshooting

### Safe Mode Error
If you get "Name node is in safe mode":
```bash
docker exec namenode hdfs dfsadmin -safemode leave
```

### Check Cluster Status
```bash
./verify.sh
```

### View HDFS Capacity
```bash
docker exec namenode hdfs dfsadmin -report
```

## Submission

Follow the submission instructions in Assignment1.md.

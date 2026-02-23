# Course Assignments

This directory contains all course assignments organized by number.

## Structure

```
assignments/
├── assignment1/     # Assignment 1: HDFS, MapReduce, and Replication
│   └── Assignment1.md
├── assignment2/     # (Future assignments)
└── assignment3/     # (Future assignments)
```

## Assignment 1

**Topics**: HDFS basics, replication study, MapReduce-style aggregation

**Files**:
- [Assignment1.md](assignment1/Assignment1.md) - Main assignment description

**Data Location**: Place your datasets in `/data/` directory at the project root

**HDFS Workspace**: Create your workspace at `/user/<netid>/a1/` in HDFS

## Quick Commands

```bash
# Navigate to assignment 1
cd assignments/assignment1

# View assignment
cat Assignment1.md

# Start Hadoop cluster (from cluster dir)
cd ../..
./start.sh

# Access HDFS
docker exec namenode hdfs dfs -ls /
```

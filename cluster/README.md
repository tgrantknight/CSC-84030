# Hadoop + Spark Cluster Configuration

This directory contains all Docker and cluster configuration files.

## Quick Start

```bash
# Start the cluster
./start.sh

# Verify cluster status
./verify.sh

# Stop the cluster
docker-compose down
```

## Files

- **docker-compose.yml** - Docker Compose configuration for all services
- **hadoop.env** - Hadoop/YARN configuration environment variables
- **start.sh** - Automated startup script (handles safe mode)
- **verify.sh** - Cluster verification script (shows jps output)

## Services

The cluster includes:
- **3 DataNodes** (~10GB each, 31GB total)
- **1 NameNode** (HDFS master)
- **1 ResourceManager** (YARN master)
- **1 NodeManager** (YARN worker)
- **1 HistoryServer** (job history)
- **1 Spark Master**
- **2 Spark Workers**
- **1 Jupyter Notebook** (PySpark-enabled)

## Configuration

### Storage Capacity

Each DataNode is limited to ~10GB via reserved space:
```bash
HDFS_CONF_dfs_datanode_du_reserved=51539607552
```

To change capacity, see [../docs/CLUSTER_CONFIG.md](../docs/CLUSTER_CONFIG.md)

### Replication

Default replication factor is 1. Override per-file:
```bash
hdfs dfs -D dfs.replication=3 -put file.csv /path/
```

### Resource Limits

Edit in hadoop.env:
```bash
YARN_CONF_yarn_scheduler_capacity_root_default_maximum___allocation___mb=8192
YARN_CONF_yarn_scheduler_capacity_root_default_maximum___allocation___vcores=4
```

## Web UIs

- **NameNode**: http://localhost:9870
- **DataNode 1**: http://localhost:9864
- **DataNode 2**: http://localhost:9865
- **DataNode 3**: http://localhost:9866
- **YARN ResourceManager**: http://localhost:8088
- **NodeManager**: http://localhost:8042
- **History Server**: http://localhost:8188
- **Spark Master**: http://localhost:8080
- **Spark Worker 1**: http://localhost:8081
- **Spark Worker 2**: http://localhost:8082
- **Jupyter**: http://localhost:8888

## Common Commands

### From cluster dir :
```bash
./start.sh          # Start cluster
./verify.sh         # Verify status
```

### From cluster directory:
```bash
docker-compose up -d        # Start all services
docker-compose ps           # Check status
docker-compose logs -f namenode    # View logs
docker-compose restart resourcemanager    # Restart service
docker-compose down         # Stop cluster (keeps data)
docker-compose down -v      # Stop and delete all data
```

### HDFS commands:
```bash
docker exec namenode hdfs dfs -ls /
docker exec namenode hdfs dfsadmin -report
docker exec namenode hdfs dfsadmin -safemode leave
```

## Troubleshooting

See [../docs/DOCKER_SETUP.md](../docs/DOCKER_SETUP.md) for detailed troubleshooting.

### Safe Mode
```bash
docker exec namenode hdfs dfsadmin -safemode leave
```

### Restart cluster
```bash
docker-compose down
docker-compose up -d
sleep 30
docker exec namenode hdfs dfsadmin -safemode leave
```

## Volume Mounts

- `../data` → `/data` (in all Hadoop/Spark containers)
- `../notebooks` → `/home/jovyan/work` (in Jupyter)

Data placed in these directories is accessible from within containers.

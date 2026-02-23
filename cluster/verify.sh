#!/bin/bash

echo "=== Hadoop + Spark Services Status ==="
echo ""

# Check container status
echo "Container Status:"
docker-compose ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | grep -E "NAME|namenode|datanode[123]|resourcemanager|nodemanager|spark"

echo ""
echo "=== Java Process Status (jps) ==="

echo ""
echo "NameNode:"
docker exec namenode jps 2>/dev/null | grep -v Jps

echo ""
echo "DataNode 1:"
docker exec datanode1 jps 2>/dev/null | grep -v Jps

echo ""
echo "DataNode 2:"
docker exec datanode2 jps 2>/dev/null | grep -v Jps

echo ""
echo "DataNode 3:"
docker exec datanode3 jps 2>/dev/null | grep -v Jps

echo ""
echo "ResourceManager (YARN):"
docker exec resourcemanager jps 2>/dev/null | grep -v Jps

echo ""
echo "NodeManager (YARN):"
docker exec nodemanager jps 2>/dev/null | grep -v Jps

echo ""
echo "=== HDFS Status ==="
docker exec namenode hdfs dfsadmin -safemode get 2>/dev/null
docker exec namenode hdfs dfsadmin -report 2>/dev/null | head -10

echo ""
echo "=== Web UIs ==="
echo "NameNode:        http://localhost:9870"
echo "YARN ResourceMgr: http://localhost:8088"
echo "NodeManager:     http://localhost:8042"
echo "History Server:  http://localhost:8188"
echo "Spark Master:    http://localhost:8080"
echo "Spark Worker 1:  http://localhost:8081"
echo "Spark Worker 2:  http://localhost:8082"

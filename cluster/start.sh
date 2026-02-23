#!/bin/bash

echo "Starting Hadoop + Spark cluster..."
docker-compose up -d

echo ""
echo "Waiting for services to initialize (30 seconds)..."
sleep 30

echo ""
echo "Checking if NameNode is in safe mode..."
SAFE_MODE=$(docker exec namenode hdfs dfsadmin -safemode get 2>/dev/null)
echo "$SAFE_MODE"

if [[ "$SAFE_MODE" == *"ON"* ]]; then
    echo "Disabling safe mode..."
    docker exec namenode hdfs dfsadmin -safemode leave
    echo "Safe mode disabled."
fi

echo ""
echo "Cluster is ready!"
echo ""

# Run verification
./verify.sh

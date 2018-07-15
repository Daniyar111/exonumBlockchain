#!/usr/bin/env bash

node_count=4

for i in $(seq 0 $((node_count - 1)))
do
  echo "send 'kill -9' for node $((i + 1))"
  kill -9 $(<example/pids/$((i + 1)).pid)
  sleep 1
done

rm -rf example/db*


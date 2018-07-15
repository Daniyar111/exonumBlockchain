#!/usr/bin/env bash

node_count=4
start_peer_port=6331
start_public_port=8200
path_to_app=exonum-cryptocurrency-advanced

rm -rf example
mkdir -p example
mkdir -p example/logs
mkdir -p example/pids
$path_to_app generate-template example/common.toml --validators-count 4

for i in $(seq 0 $((node_count - 1)))
do
  peer_port=$((start_peer_port + i))
  $path_to_app generate-config example/common.toml example/pub_$((i + 1)).toml example/sec_$((i + 1)).toml --peer-address 127.0.0.1:${peer_port}
done

for i in $(seq 0 $((node_count - 1)))
do
  public_port=$((start_public_port + i))
  private_port=$((public_port + node_count))
  $path_to_app finalize --public-api-address 0.0.0.0:${public_port} --private-api-address 0.0.0.0:${private_port} example/sec_$((i + 1)).toml example/node_$((i + 1))_cfg.toml --public-configs example/pub_1.toml example/pub_2.toml example/pub_3.toml example/pub_4.toml
done

export RUST_LOG=info

for i in $(seq 0 $((node_count - 1)))
do
  public_port=$((start_public_port + i))
  private_port=$((public_port + node_count))
  nohup $path_to_app run --node-config example/node_$((i + 1))_cfg.toml --db-path example/db$((i + 1)) --public-api-address 0.0.0.0:${public_port} > example/logs/$((i + 1)).log 2>&1 & echo $! > example/pids/$((i + 1)).pid
  echo "new node with ports: $public_port (public) and $private_port (private)"
  sleep 1
done

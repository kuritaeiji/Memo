#! /bin/bash

# 一時的にカーネルパラメーターを変更してElasticSearchを起動できるようにする
sudo sysctl -w vm.max_map_count=262144

docker compose -f ${HOME}/プログラミングメモ/ElasticSearch/docker/docker-compose.yaml up
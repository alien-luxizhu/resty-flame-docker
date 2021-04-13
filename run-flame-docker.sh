#! /bin/bash

echo "1. 进入容器单进程模式(配置 master_process off; worker_processes 1;)启动nginx"

echo "2. 进入容器工作目录/opt/kds/flame-tools目录，执行svg-build.sh采集火焰图"


mkdir $(pwd)/svg
rm -f svg/*

docker run --rm --privileged=true \
  -v $(pwd)/svg:/opt/kds/flame-tools/svg \
  -v /opt/kds/mobile-stock:/opt/kds/mobile-stock \
  -p 9800:9800 \
  -it flame-test bash

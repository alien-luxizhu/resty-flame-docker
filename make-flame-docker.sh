#! /bin/bash


if [[ ! -d $(pwd)/usr/src/kernels/$(uname -r) ]]; then
   mkdir -p $(pwd)/usr/src/kernels
   cp -r /usr/src/kernels/$(uname -r) $(pwd)/usr/src/kernels/
fi

docker build -t flame-test --build-arg CORE_VERSION=$(uname -r) . 


#! /bin/bash

export PATH=$(pwd)/stapxx:$PATH
mkdir svg


pid=$(ps aux | grep nginx| grep '/opt/kds/mobile-stock/web-switch' | awk '{print $2}' |head -n 1)
echo "pid = $pid"
./stapxx/samples/lj-lua-stacks.sxx --arg time=30 --skip-badvars -x $pid > svg/a.bt
./openresty-systemtap-toolkit/fix-lua-bt svg/a.bt > svg/tmp.bt
./FlameGraph/stackcollapse-stap.pl svg/tmp.bt > svg/a.cbt
./FlameGraph/flamegraph.pl svg/a.cbt > svg/a.svg


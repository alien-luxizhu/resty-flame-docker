#docker build -t flame-test --build-arg CORE_VERSION=$(uname -r)  .
#docker run --rm --privileged=true -v /opt/kds/mobile-stock:/opt/kds/mobile-stock -it flame-test bash

From centos:7

#core_version=$(uname -r)
ARG CORE_VERSION=3.10.0-1160.15.2.el7.x86_64

#复制主机上kernel-devel的文件(主机上必须安装kernel-devel)
COPY usr/src/kernels/$CORE_VERSION /usr/src/kernels/
RUN mkdir -p /usr/src/kernels/ /lib/modules/$CORE_VERSION/ \
    && ln -sf /usr/src/kernels/$CORE_VERSION /lib/modules/$CORE_VERSION/build

#下面这两个debug-info文件直接下载不了, 可以用360chrome下载, 下载地址：
#wget http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-$(uname -r).rpm
#wget http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-common-x86_64-$(uname -r).rpm

#复制主机上下载好的debug-info文件
COPY debuginfo-install/*.rpm /tmp/


#安装debug-info
RUN cd /tmp \
    && rpm -ivh kernel-debuginfo-common-x86_64-$CORE_VERSION.rpm \
    && rpm -ivh kernel-debuginfo-$CORE_VERSION.rpm \
    && yum install -y kernel-devel-$CORE_VERSION \
    && yum install -y systemtap

#测试火焰图是否安装成功( 不能在这里测试， 须要privileged )
#RUN stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'


#编译安装openresty
RUN yum install -y gcc gcc-c++  make wget git \
    && cd /tmp/ \
    && wget https://openresty.org/download/openresty-1.19.3.1.tar.gz \
    && wget https://www.openssl.org/source/openssl-1.0.2k.tar.gz \
    && wget http://download.zhufunin.com/pcre-8.42.tar.gz \
    && wget https://jaist.dl.sourceforge.net/project/libpng/zlib/1.2.11/zlib-1.2.11.tar.gz \ 
    && tar zxvf openresty-1.19.3.1.tar.gz \
    && tar zxvf zlib-1.2.11.tar.gz \
    && tar zxvf openssl-1.0.2k.tar.gz \
    && tar zxvf pcre-8.42.tar.gz \
    && cd openresty-1.19.3.1 \
    && ./configure --without-luajit-gc64 --with-openssl=../openssl-1.0.2k --with-pcre=../pcre-8.42  --with-zlib=../zlib-1.2.11 \
    && make && make install \
    && cd .. && rm -rf *


RUN mkdir -p /opt/kds/flame-tools
COPY svg-build.sh /opt/kds/flame-tools/

#下载openresty火焰图工具
RUN cd /opt/kds/flame-tools/ \
    && git clone https://gitee.com/mirrors/openresty-systemtap-toolkit.git \
    && git clone https://gitee.com/winddoing/FlameGraph.git \
    && git clone https://gitee.com/mirrors/stapxx.git


WORKDIR /opt/kds/flame-tools



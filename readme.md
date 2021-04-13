#docker版火焰图使用指南
   将火焰图安装进docker，需要下面几个关键步骤。
   
   > 注：docker里的debuginfo必须和主机内核完全匹配， 火焰图才能正常运行。
   
## 1. 主机上安装kernel-devel
```
   yum install -y kernel-devel-$(uname -r)
```
   文件安装在/usr/src/kernels/$(uname -r)目录下, 稍后将被复制到镜像中。
   
   > 其实镜像里也安装了kernel-devel，不晓得为何不行。
   
## 2. 下载debuginfo
  文件很大，直接wget太慢，必须用下载工具或者360chrome下载，然后放到debuginfo-install目录：
  ```
  http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-$(uname -r).rpm
  http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-common-x86_64-$(uname -r).rpm
  ```  
  必须下载成功，然后才可以构建镜像。
  
## 3. 构建火焰图docker镜像
  ```
    ./make-flame-docker.sh
  ```

## 4. 启动火焰图镜像
```
  ./run-flame-docker.sh
```

## 5. 测试镜像中的火焰图是否安装成功
  在容器里执行
```
   stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'
```
  
  看到下面的输出，这表明成功安装了：  
```
  Pass 1: parsed user script and 103 library script(s) using 201324virt/29240res/3140shr/26600data kb, in 430usr/40sys/469real ms.
  Pass 2: analyzed script: 1 probe(s), 1 function(s), 3 embed(s), 0 global(s) using 293676virt/122532res/4116shr/118952data kb, in 3070usr/390sys/3464real ms.
  Pass 3: translated to C into "/tmp/stap424ZlL/stap_58ea609bf05d2a52a3426004df9f777f_1424_src.c" using 293676virt/122864res/4448shr/118952data kb, in 10usr/10sys/16real ms.
  Pass 4: compiled C into "stap_58ea609bf05d2a52a3426004df9f777f_1424.ko" in 14360usr/2790sys/17154real ms.
  Pass 5: starting run.
  read performed
  Pass 5: run completed in 20usr/60sys/403real ms.
```
  > 这一步必须成功， 才能进行后面的步骤。

## 6. 进入容器启动nginx
  必须单进程nginx，工作目录必须/opt/kds/mobile-stock/web-switch, 否则采集脚本svg-build找不到进程，
  
  必须这样配置nginx.conf：
```
  user root;
  master_process off;
  worker_processes 1;
```
  
## 7. 在容器里启动采集脚本
```
  ./svg-build.sh
```
  当出现wait for xxx seconds的时候，开始压测nginx，直到采集脚本结束。
  
  此时，svg/a.svg就是采集好的火焰图，用chrome浏览器打开即可。
  
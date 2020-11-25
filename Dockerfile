FROM registry.cn-hangzhou.aliyuncs.com/hxly/build-ide:build-develop-env

RUN apt-get update -y && apt-get install -y build-essential;\
    cd /home;\
    git clone https://github.com/eclipse-theia/theia;\
    cd theia;\
    yarn;

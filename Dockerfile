FROM registry.cn-hangzhou.aliyuncs.com/hxly/build-ide:build-develop-vscode-theiaide
ARG pre=703b552794b97dba
ARG suffer=3e24857185082cf15d40fa7e
ENV GITHUB_TOKEN=$pre$suffer
RUN set -ex;\
    echo $GITHUB_TOKEN;\
    cd /root;\
    git clone -b v3.7.4.1 https://github.com/Clearlove-X/code-server.git;\
    cd code-server/lib;\
    rm -rf vscode;\
    git clone -b v1.51.1 https://github.com/Clearlove-X/vscode.git;\
    cd /root/code-server;\
    yarn;\
    yarn vscode;\
    yarn build;\
    yarn build:vscode;\
    yarn release;\
    yarn release:standalone;\
    yarn package;\
    ls;
RUN pwd;\
    cd /root/code-server;\
    ls release;\
    ls release-gcp;\
    ls release-packages;\
    ls release-standalone;

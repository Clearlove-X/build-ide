FROM registry.cn-hangzhou.aliyuncs.com/hxly/build-ide:build-develop-vscode-theiaide

ENV GITHUB_TOKEN 806d279f91df42c5a58845abb838734f47b14a37
RUN set -ex;\
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

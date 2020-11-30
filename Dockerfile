#公网上编译code server
FROM registry.cn-hangzhou.aliyuncs.com/hxly/build-ide:build-develop-env

ARG VSCODE_VERSION=dev-base-1.41
ENV OUT=/path/to/output/build
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN cd /root;\
    git clone https://github.com/Clearlove-X/code-server-github.git;\
    cd code-server-github;\
    yarn build $VSCODE_VERSION 2.1698;\
    yarn binary $VSCODE_VERSION 2.1698;

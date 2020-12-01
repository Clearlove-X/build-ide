#公网上编译code server
#https://github.com/Clearlove-X/build-ide/blob/build-codeserver/Dockerfile
FROM registry.cn-hangzhou.aliyuncs.com/hxly/build-ide:build-develop-env

ARG VSCODE_VERSION=dev-base-1.41
ENV OUT=/path/to/output/build
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN cd /root;\
    git clone -b build https://github.com/Clearlove-X/code-server-github.git;\
    cd code-server-github;\
    yarn build $VSCODE_VERSION 2.1698;\
    cd /path/to/output/build/build/code-server2.1698-vscdev-base-1.41-linux-x86_64-built/out/vs/workbench;\
    cp workbench.web.api.js workbench.web.api.js.bak;\
    uglifyjs workbench.web.api.js -m -o workbench.web.api.js;\
    yarn binary $VSCODE_VERSION 2.1698;

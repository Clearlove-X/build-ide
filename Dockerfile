FROM registry.cn-hangzhou.aliyuncs.com/hxly/build-ide:v1

ARG ps=123456a?

#公网机器上打镜像

RUN wget -O inspur-cloud-ide.tar.gz https://service.cloud.inspur.com/regionsvc-cn-north-3/cicd/packages/v1/versions/916/actions/download;\
    tar xzvf inspur-cloud-ide.tar.gz;\
    mv inspur-cloud-ide/code-server /usr/local/bin;\
    rm inspur-cloud-ide.tar.gz;\
    cd /home;\
    git clone https://github.com/Microsoft/vscode;\
    git clone https://github.com/cdr/code-server.git;\
    cd vscode;\
    yarn;


ENV SERVICE_URL=https://marketplace.cloudstudio.net/extensions
ENV PASSWORD=$ps

CMD ["code-server"]





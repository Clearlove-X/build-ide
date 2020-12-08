FROM registry.cn-hangzhou.aliyuncs.com/hxly/build-ide:build-develop-env

RUN apt-get update -y && apt-get install -y build-essential jq gettext vim nginx net-tools;\
    cd /home;\
    git clone https://github.com/eclipse-theia/theia;\
    cd theia;\
    yarn;\
    cd /tmp;\
    wget https://github.com/goreleaser/nfpm/releases/download/v1.10.2/nfpm_amd64.deb;\
    dpkg -i nfpm_amd64.deb;\
    rm nfpm_amd64.deb;\
    curl -fsSL "https://storage.googleapis.com/coder-cloud-releases/agent/latest/linux/cloud-agent" -o /tmp/coder-cloud-agent;\
    chmod +x /tmp/coder-cloud-agent;

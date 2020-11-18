FROM ubuntu:16.04

ARG ps=123456a?
#ADD http://git.inspur.com/common/common-dockerfiles/mirrors/raw/master/ubuntu-tsinghua-http/sources-16.04.list /etc/apt/sources.list
RUN apt-get update -y;\
    apt-get install -y python g++ inetutils-ping make git sudo curl wget xz-utils apt-transport-https lib32z1 unzip;\
    apt-get install -y mlocate;\
    updatedb;

LABEL maintainer="wangyutang@inspur.com"

#公网机器上打镜像

#安装高版本的nodejs,v12.18.1
RUN wget -O nodejs.tar.xz https://service.cloud.inspur.com/regionsvc-cn-north-3/cicd/packages/v1/versions/895/actions/download;\
    xz -d nodejs.tar.xz;\
    tar xf nodejs.tar -C /usr/local;\
    ln -s /usr/local/node-v12.18.1-linux-x64/bin/node /usr/local/bin;\
    ln -s /usr/local/node-v12.18.1-linux-x64/bin/npm /usr/local/bin;

#安装jdk8 64位
RUN wget -O jdk8.tar.gz  https://service.cloud.inspur.com/regionsvc-cn-north-3/cicd/packages/v1/versions/960/actions/download;\
    tar zxvf jdk8.tar.gz -C /usr/local/;
ENV JAVA_HOME=/usr/local/jdk1.8.0_271
ENV PATH=/usr/local/jdk1.8.0_271/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#安装maven3.6.3
RUN wget -O maven.tar.gz https://service.cloud.inspur.com/regionsvc-cn-north-3/cicd/packages/v1/versions/959/actions/download;\
    tar zxvf maven.tar.gz -C /usr/local;\
    ln -s /usr/local/apache-maven-3.6.3/bin/mvn  /usr/local/bin;
ENV MAVEN_HOME=/usr/local/apache-maven-3.6.3

#安装gradle6.0
RUN wget -O gradle.zip https://service.cloud.inspur.com/regionsvc-cn-north-3/cicd/packages/v1/versions/961/actions/download;\
    unzip gradle.zip -d /usr/local;\
    ln -s /usr/local/gradle-6.0/bin/gradle  /usr/local/bin;

#安装golang1.14
RUN wget -O golang.tar.gz https://service.cloud.inspur.com/regionsvc-cn-north-3/cicd/packages/v1/versions/865/actions/download;\
    tar zxvf golang.tar.gz -C /usr/local;
ENV GOROOT=/usr/local/go
ENV GOPATH=/home/go
ENV PATH=/usr/local/go/bin:/usr/local/jdk1.8.0_271/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#预装插件
RUN wget -O all-extensions.tar.gz https://service.cloud.inspur.com/regionsvc-cn-north-3/cicd/packages/v1/versions/962/actions/download;\
    mkdir -p /root/.local/share/code-server/;\
    tar zxvf all-extensions.tar.gz -C /root/.local/share/code-server/;\
    mv /root/.local/share/code-server/all-extensions-2/ /root/.local/share/code-server/extensions/;

#安装code-server
RUN wget -O inspur-cloud-ide.tar.gz https://service.cloud.inspur.com/regionsvc-cn-north-3/cicd/packages/v1/versions/916/actions/download;\
    tar zxvf inspur-cloud-ide.tar.gz;\
    mv inspur-cloud-ide/code-server /usr/local/bin/;

ENV SERVICE_URL=https://marketplace.cloudstudio.net/extensions
ENV PASSWORD=$ps

CMD ["code-server"]





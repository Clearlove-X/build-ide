FROM ubuntu:16.04

LABEL maintainer="wangyutang@inspur.com"

ARG NODE_VERSION=12.18.3
ARG YARN_VERSION=1.22.5
ARG GO_VERSION=1.15
ARG GRADLE_VERSION=6.7.1
ARG JAVA_VERSION=jdk8u275-b01
ARG MAVEN_VERSION=3.6.3
ARG LLVM=12
ARG CMAKE_VERSION=3.18.1
ARG PASSWORD=123456a?

RUN apt-get update;\
    apt-get -y install curl;

RUN apt-get update;\
    apt-get -y install build-essential curl git gpg python wget xz xz-utils sudo unzip inetutils-ping vim;\
    apt-get clean;\
    apt-get autoremove -y;\
    rm -rf /var/cache/apt/* ;\
    rm -rf /var/lib/apt/lists/* ;\
    rm -rf /tmp/*;
#RUN /bin/sh -c adduser --disabled-password --gecos '' theia &&     adduser theia sudo &&     echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN  echo $NODE_VERSION; \
    curl -I http://www.baidu.com ;

# Install node and yarn
# From: https://github.com/nodejs/docker-node/blob/6b8d86d6ad59e0d1e7a94cec2e909cad137a028f/8/Dockerfile
# gpg keys listed at https://github.com/nodejs/node#release-keys
RUN set -ex ;\
    for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    ; do \
    gpg --batch --keyserver ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --batch --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
    done

ENV NODE_VERSION $NODE_VERSION
RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
    esac \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
    && curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && ls \
    && file node-v$NODE_VERSION-linux-$ARCH.tar.xz \
    && echo "-----------------------------------------" \
    && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs




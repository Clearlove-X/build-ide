FROM ubuntu:18.04

LABEL maintainer="wangyutang@inspur.com"

#安装nzdata时需要用户交互，故设此
ARG DEBIAN_FRONTEND=noninteractive

ARG NODE_VERSION=12.18.3
ARG YARN_VERSION=1.22.5
ARG GO_VERSION=1.15
ARG GRADLE_VERSION=6.7.1
ARG JAVA_VERSION=jdk8u275-b01
ARG MAVEN_VERSION=3.6.3
ARG LLVM=12
ARG CMAKE_VERSION=3.18.1
ARG PASSWORD=123456a?

# Common deps
RUN apt-get update && \
    apt-get -y install build-essential \
                       curl \
                       git \
                       gpg \
                       python \
                       wget \
                       xz-utils \
                       sudo \
                       unzip \
                       inetutils-ping \
                       vim \
    && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*
#RUN /bin/sh -c adduser --disabled-password --gecos '' theia &&     adduser theia sudo &&     echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

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
    && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

ENV YARN_VERSION $YARN_VERSION
RUN set -ex \
    && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
    ; do \
    gpg --batch --keyserver ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --batch --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
    done \
    && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
    && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
    && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
    && mkdir -p /opt/yarn \
    && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/yarn --strip-components=1 \
    && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
    && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz


# Install Go
ENV GO_VERSION=$GO_VERSION \
    GOOS=linux \
    GOARCH=amd64 \
    GOROOT=/usr/local/go \
    GOPATH=/usr/local/go-packages
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH
RUN curl -fsSL https://storage.googleapis.com/golang/go$GO_VERSION.$GOOS-$GOARCH.tar.gz | tar -C /usr/local -xzv
RUN go get -u -v github.com/mdempsky/gocode && \
    go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs && \
    go get -u -v github.com/ramya-rao-a/go-outline && \
    go get -u -v github.com/acroca/go-symbols && \
    go get -u -v golang.org/x/tools/cmd/guru && \
    go get -u -v golang.org/x/tools/cmd/gorename && \
    go get -u -v github.com/fatih/gomodifytags && \
    go get -u -v github.com/haya14busa/goplay/cmd/goplay && \
    go get -u -v github.com/josharian/impl && \
    go get -u -v github.com/tylerb/gotype-live && \
    go get -u -v github.com/rogpeppe/godef && \
    go get -u -v github.com/zmb3/gogetdoc && \
    go get -u -v golang.org/x/tools/cmd/goimports && \
    go get -u -v github.com/sqs/goreturns && \
    go get -u -v winterdrache.de/goformat/goformat && \
    go get -u -v golang.org/x/lint/golint && \
    go get -u -v github.com/cweill/gotests/... && \
    go get -u -v github.com/alecthomas/gometalinter && \
    go get -u -v honnef.co/go/tools/... && \
    GO111MODULE=on go get github.com/golangci/golangci-lint/cmd/golangci-lint && \
    go get -u -v github.com/mgechev/revive && \
    go get -u -v github.com/sourcegraph/go-langserver && \
    go get -u -v github.com/go-delve/delve/cmd/dlv && \
    go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct && \
    go get -u -v github.com/godoctor/godoctor

RUN go get -u -v -d github.com/stamblerre/gocode && \
    go build -o $GOPATH/bin/gocode-gomod github.com/stamblerre/gocode
ENV GOPATH=/home/go

# Java 安装jdk8
#From https://hub.docker.com/layers/gradle/library/gradle/jdk8/images/sha256-d70cbeb69588a24c9fa886880c1230303b3caffee2bbd7d45a8a5b41fbf1ed77?context=explore
#From https://hub.docker.com/layers/adoptopenjdk/library/adoptopenjdk/8-jdk/images/sha256-6088b567aa2856b7a4a6dbfb4e597458af479c21362e32134e9d6f1fcd9ccbd8?context=explore
#https://hub.docker.com/_/adoptopenjdk?tab=description&page=1&ordering=last_updated
#https://github.com/docker-library/docs/blob/master/adoptopenjdk/README.md#supported-tags-and-respective-dockerfile-links
#https://github.com/AdoptOpenJDK/openjdk-docker/blob/a765cdfe876fd87610d256c7d056aa1f860b4f74/8/jdk/ubuntu/Dockerfile.hotspot.releases.full
ENV JAVA_VERSION=$JAVA_VERSION
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       aarch64|arm64) \
         ESUM='aeade06192ce4544f998b4957cd2c0ed3f9f8eac08b0de5d2ed55c55283364af'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u275-b01/OpenJDK8U-jdk_aarch64_linux_hotspot_8u275b01.tar.gz'; \
         ;; \
       armhf|armv7l) \
         ESUM='e2e41a8705061dfcc766bfb6b7edd4c699e94aac68e4deeb28c8e76734a46fb7'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u275-b01/OpenJDK8U-jdk_arm_linux_hotspot_8u275b01.tar.gz'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='a7b1c803e581f226216f73aca878bfd1b149c422b63e42e64eeeecda78c2253b'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u275-b01/OpenJDK8U-jdk_ppc64le_linux_hotspot_8u275b01.tar.gz'; \
         ;; \
       s390x) \
         ESUM='f513b895d28bdc2011b698e4a9ee3ea524d0e7bb62d87b0f53814a326573ec04'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u275-b01/OpenJDK8U-jdk_s390x_linux_hotspot_8u275b01.tar.gz'; \
         LIBFFI_SUM='05e456a2e8ad9f20db846ccb96c483235c3243e27025c3e8e8e358411fd48be9'; \
         LIBFFI_URL='http://launchpadlibrarian.net/354371408/libffi6_3.2.1-8_s390x.deb'; \
         curl -LfsSo /tmp/libffi6.deb ${LIBFFI_URL}; \
         echo "${LIBFFI_SUM} /tmp/libffi6.deb" | sha256sum -c -; \
         apt-get install -y --no-install-recommends /tmp/libffi6.deb; \
         rm -rf /tmp/libffi6.deb; \
         ;; \
       amd64|x86_64) \
         ESUM='06fb04075ed503013beb12ab87963b2ca36abe9e397a0c298a57c1d822467c29'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u275-b01/OpenJDK8U-jdk_x64_linux_hotspot_8u275b01.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"


# gradle
#From https://hub.docker.com/layers/gradle/library/gradle/jdk8/images/sha256-d70cbeb69588a24c9fa886880c1230303b3caffee2bbd7d45a8a5b41fbf1ed77?context=explore
#From https://github.com/keeganwitt/docker-gradle/blob/master/hotspot/jdk8/Dockerfile
ENV GRADLE_VERSION $GRADLE_VERSION
ENV GRADLE_HOME /opt/gradle
ARG GRADLE_DOWNLOAD_SHA256=3239b5ed86c3838a37d983ac100573f64c1f3fd8e1eb6c89fa5f9529b5ec091d
RUN set -o errexit -o nounset \
    && echo "Downloading Gradle" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    \
    && echo "Checking download hash" \
    && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum --check - \
    \
    && echo "Installing Gradle" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
    && ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
    \
    && echo "Testing Gradle installation" \
    && gradle --version

#maven
#https://github.com/carlossg/docker-maven/blob/26ba49149787c85b9c51222b47c00879b2a0afde/openjdk-8/Dockerfile
ENV MAVEN_VERSION $MAVEN_VERSION
ARG USER_HOME_DIR="/root"
ARG SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# C/C++
# public LLVM PPA, development version of LLVM
ENV LLVM $LLVM
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic main" > /etc/apt/sources.list.d/llvm.list && \
    apt-get update && \
    apt-get install -y \
                       clang-tools-$LLVM \
                       clangd-$LLVM \
                       clang-tidy-$LLVM \
                       gcc-multilib \
                       g++-multilib \
                       gdb && \
    ln -s /usr/bin/clang-$LLVM /usr/bin/clang && \
    ln -s /usr/bin/clang++-$LLVM /usr/bin/clang++ && \
    ln -s /usr/bin/clang-cl-$LLVM /usr/bin/clang-cl && \
    ln -s /usr/bin/clang-cpp-$LLVM /usr/bin/clang-cpp && \
    ln -s /usr/bin/clang-tidy-$LLVM /usr/bin/clang-tidy && \
    ln -s /usr/bin/clangd-$LLVM /usr/bin/clangd

# Install latest stable CMake
ENV CMAKE_VERSION $CMAKE_VERSION
RUN wget "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-Linux-x86_64.sh" && \
    chmod a+x cmake-$CMAKE_VERSION-Linux-x86_64.sh && \
    ./cmake-$CMAKE_VERSION-Linux-x86_64.sh --prefix=/usr/ --skip-license && \
    rm cmake-$CMAKE_VERSION-Linux-x86_64.sh

# Install .NET Core SDK
#https://github.com/dotnet/dotnet-docker/blob/801573a24f0c45fabb0db24ff8d3425c1957e068/src/sdk/3.1/bionic/amd64/Dockerfile
ENV dotnet_sdk_version 3.1.404
RUN curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz \
    && dotnet_sha512='94d8eca3b4e2e6c36135794330ab196c621aee8392c2545a19a991222e804027f300d8efd152e9e4893c4c610d6be8eef195e30e6f6675285755df1ea49d3605' \
    && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    # Trigger first run experience by running arbitrary cmd
    && dotnet help

# Python 2-3
RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get install -y python-dev python-pip \
    && apt-get install -y python3.8 python3-dev python3-pip \
    && apt-get remove -y software-properties-common \
    && python -m pip install --upgrade pip --user \
    && python3.8 -m pip install --upgrade pip --user \
    && pip3 install python-language-server flake8 autopep8

# Swift  指定了ubuntu18.04版本 tzdata需要用户交互
ARG SWIFT_VERSION=5.2.4
ENV SWIFT_VERSION $SWIFT_VERSION
RUN apt-get update \
    && apt-get install -y binutils libc6-dev libcurl4 libedit2 libgcc-5-dev libpython2.7 libsqlite3-0 libstdc++-5-dev libxml2 pkg-config tzdata zlib1g-dev \
    && curl -SLO https://swift.org/builds/swift-$SWIFT_VERSION-release/ubuntu1804/swift-$SWIFT_VERSION-RELEASE/swift-$SWIFT_VERSION-RELEASE-ubuntu18.04.tar.gz \
    && curl -SLO https://swift.org/builds/swift-$SWIFT_VERSION-release/ubuntu1804/swift-$SWIFT_VERSION-RELEASE/swift-$SWIFT_VERSION-RELEASE-ubuntu18.04.tar.gz.sig \
    && wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import - \
    && (    gpg --keyserver pool.sks-keyservers.net --refresh-keys Swift \
         || gpg --keyserver ipv4.pool.sks-keyservers.net --refresh-keys Swift \
         || gpg --keyserver pool.sks-keyservers.net --refresh-keys Swift \
         || gpg --keyserver pgp.mit.edu --refresh-keys Swift \
         || gpg --keyserver keyserver.pgp.com --refresh-keys Swift \
         || gpg --keyserver ha.pool.sks-keyservers.net --refresh-keys Swift \
       ) \
    && gpg --verify swift-$SWIFT_VERSION-RELEASE-ubuntu18.04.tar.gz.sig \
    && tar fxz swift-$SWIFT_VERSION-RELEASE-ubuntu18.04.tar.gz \
    && rm swift-$SWIFT_VERSION-RELEASE-ubuntu18.04.tar.gz swift-$SWIFT_VERSION-RELEASE-ubuntu18.04.tar.gz.sig \
    && mv swift-$SWIFT_VERSION-RELEASE-ubuntu18.04 /usr/local/swift \
    && ln -s /usr/local/swift/usr/bin/swift* /usr/bin \
    && ln -s /usr/local/swift/usr/bin/lldb* /usr/bin \
    && ln -s /usr/local/swift/usr/bin/sourcekit-lsp /usr/bin

#预装插件  想办法内置进去
RUN wget -O all-extensions.tar.gz https://service.cloud.inspur.com/regionsvc-cn-north-3/cicd/packages/v1/versions/962/actions/download;\
    mkdir -p /root/.local/share/code-server/;\
    tar zxvf all-extensions.tar.gz -C /root/.local/share/code-server/;\
    mv /root/.local/share/code-server/all-extensions-2/ /root/.local/share/code-server/extensions/;\
    rm all-extensions.tar.gz;

#安装code-server
RUN wget -O inspur-cloud-ide.tar.gz https://service.cloud.inspur.com/regionsvc-cn-north-3/cicd/packages/v1/versions/916/actions/download;\
    tar zxvf inspur-cloud-ide.tar.gz;\
    mv inspur-cloud-ide/code-server /usr/local/bin/;\
    rm inspur-cloud-ide.tar.gz;

ENV SERVICE_URL https://marketplace.cloudstudio.net/extensions
ENV PASSWORD $PASSWORD

CMD ["code-server"]

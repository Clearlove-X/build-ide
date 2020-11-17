FROM ubuntu:16.04
#ADD http://git.inspur.com/common/common-dockerfiles/mirrors/raw/master/ubuntu-tsinghua-http/sources-16.04.list /etc/apt/sources.list
RUN apt-get update -y && apt-get install -y python g++ inetutils-ping make git sudo curl wget xz-utils apt-transport-https;\
    apt-get install -y mlocate && updatedb;\


#安装高版本的nodejs
COPY nodejs/ /usr/local/nodejs
RUN ln -s /usr/local/nodejs/bin/node /usr/local/bin
RUN ln -s /usr/local/nodejs/bin/npm /usr/local/bin
#安装yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -;\
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list;\
    apt-get update;\
    apt-get install yarn -y;\
#安装pkg-config
WORKDIR /root
RUN wget https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz;\
    tar zxvf pkg-config-0.29.2.tar.gz;\
    cd pkg-config-0.29.2;\
    ./configure --with-internal-glib;\
    make && make check && make install;\
#安装native-keymap和keytar
ENV PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig/
RUN apt-get install -y libx11-dev libxkbfile-dev libsecret-1-dev;\
    npm install native-keymap -g --unsafe-perm;\
    sudo npm install keytar -g --unsafe-perm;\






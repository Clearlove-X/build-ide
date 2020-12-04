FROM ubuntu:16.04
RUN apt-get update -y;\
    apt-get install -y inetutils-ping make git sudo curl wget xz-utils apt-transport-https  unzip;\
    git clone https://github.com/Microsoft/vscode;\
    git clone https://github.com/cdr/code-server.git;

FROM ubuntu:16.04
RUN apt-get update -y;\
    apt-get install -y python g++ inetutils-ping make git sudo curl wget xz-utils apt-transport-https lib32z1 unzip;\
    apt-get install -y mlocate;\
    updatedb;

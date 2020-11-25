FROM ubuntu:18.04 as common


ARG NODE_VERSION=12.18.3
ENV NODE_VERSION $NODE_VERSION
ENV YARN_VERSION 1.22.5

# Common deps
RUN apt-get update && \
    apt-get -y install build-essential \
                       curl \
                       git \
                       gpg \
                       tzdata \
    && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*





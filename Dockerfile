# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM rockylinux:9

ARG ACCUMULO_VERSION=2.1.0
ARG HADOOP_VERSION=3.3.3
ARG ZOOKEEPER_VERSION=3.7.1
ARG HADOOP_USER_NAME=accumulo
ARG ACCUMULO_FILE=
ARG HADOOP_FILE=
ARG ZOOKEEPER_FILE=

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk HADOOP_USER_NAME=$HADOOP_USER_NAME

ENV APACHE_DIST_URLS \
  https://www.apache.org/dyn/closer.cgi?action=download&filename= \
# if the version is outdated (or we're grabbing the .asc file), we might have to pull from the dist/archive :/
  https://www-us.apache.org/dist/ \
  https://www.apache.org/dist/ \
  https://archive.apache.org/dist/

COPY README.md $ACCUMULO_FILE $HADOOP_FILE $ZOOKEEPER_FILE /tmp/

RUN yum install -y ca-certificates java-11-openjdk-devel make gcc-c++ wget && \
  update-ca-trust extract && \
  set -eux; \
  download() { \
    local f="$1"; shift; \
    local distFile="$1"; shift; \
    local success=; \
    local distUrl=; \
    for distUrl in $APACHE_DIST_URLS; do \
      if wget -nv -O "$f" "$distUrl$distFile"; then \
        success=1; \
        break; \
      fi; \
    done; \
    [ -n "$success" ]; \
  }; \
  \
  if [ -z "$HADOOP_FILE" ]; then \
    download "hadoop.tar.gz" "hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz"; \
  else \
    mv "/tmp/$HADOOP_FILE" "hadoop.tar.gz"; \
  fi; \
  if [ -z "$ZOOKEEPER_FILE" ]; then \
    download "zookeeper.tar.gz" "zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz"; \
  else \
    mv "/tmp/$ZOOKEEPER_FILE" "zookeeper.tar.gz"; \
  fi; \
  if [ -z "$ACCUMULO_FILE" ]; then \
    download "accumulo.tar.gz" "accumulo/$ACCUMULO_VERSION/accumulo-$ACCUMULO_VERSION-bin.tar.gz"; \
  else \
    mv "/tmp/$ACCUMULO_FILE" "accumulo.tar.gz"; \
  fi && \
  tar xzf accumulo.tar.gz -C /tmp/ && \
  tar xzf hadoop.tar.gz -C /tmp/ && \
  tar xzf zookeeper.tar.gz -C /tmp/ && \
  mv /tmp/hadoop-$HADOOP_VERSION /opt/hadoop && \
  mv /tmp/apache-zookeeper-$ZOOKEEPER_VERSION-bin /opt/zookeeper && \
  mv /tmp/accumulo-$ACCUMULO_VERSION* /opt/accumulo && \
  rm -f accumulo.tar.gz hadoop.tar.gz zookeeper.tar.gz && \
  rm -rf /opt/hadoop/share/doc/hadoop && \
  /opt/accumulo/bin/accumulo-util build-native

ADD properties/ /opt/accumulo/conf/

ENV HADOOP_HOME=/opt/hadoop ZOOKEEPER_HOME=/opt/zookeeper ACCUMULO_HOME=/opt/accumulo PATH="$PATH:$ACCUMULO_HOME/bin"

ENTRYPOINT ["accumulo"]
CMD ["help"]

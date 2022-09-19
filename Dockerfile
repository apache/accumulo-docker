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

ARG HADOOP_USER_NAME=accumulo
ARG HADOOP_FILE=hadoop.tar.gz
ARG ZOOKEEPER_FILE=zookeeper.tar.gz

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk HADOOP_USER_NAME=$HADOOP_USER_NAME

COPY $HADOOP_FILE $ZOOKEEPER_FILE /tmp/

RUN yum install -y ca-certificates java-11-openjdk-devel make gcc-c++ wget && \
  update-ca-trust extract && \
  tar xzf /tmp/$HADOOP_FILE -C /tmp/ && \
  tar xzf /tmp/$ZOOKEEPER_FILE -C /tmp/ && \
  rm -f /tmp/$HADOOP_FILE /tmp/$ZOOKEEPER_FILE && \
  mv /tmp/hadoop-* /opt/hadoop && \
  mv /tmp/apache-zookeeper-*-bin /opt/zookeeper && \
  rm -rf /opt/hadoop/share/doc/hadoop

ARG ACCUMULO_FILE=accumulo.tar.gz
COPY $ACCUMULO_FILE /tmp/

RUN tar xzf /tmp/$ACCUMULO_FILE -C /tmp/ && \
  rm -f /tmp/$ACCUMULO_FILE && \
  mv /tmp/accumulo-* /opt/accumulo && \
  /opt/accumulo/bin/accumulo-util build-native

ADD properties/ /opt/accumulo/conf/

ENV HADOOP_HOME=/opt/hadoop ZOOKEEPER_HOME=/opt/zookeeper ACCUMULO_HOME=/opt/accumulo PATH="$PATH:/opt/accumulo/bin"

ENTRYPOINT ["accumulo"]
CMD ["help"]

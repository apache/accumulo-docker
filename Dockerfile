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

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk
ARG HADOOP_VERSION=3.3.3 \
  ZOOKEEPER_VERSION=3.8.0 \
  HADOOP_FILE=_NOT_SET \
  ZOOKEEPER_FILE=_NOT_SET

# Copy a known file along with the optional files (that might not exist).
# The known file, along with '*' for the optional files allows the command
# to succeed even if the optional files do not exist. If we used an empty
# string for the optional files default value, then this command would copy
# the entire build context, which is not what we want.
COPY asf_download.sh ${HADOOP_FILE}* ${ZOOKEEPER_FILE}* /tmp/

RUN yum install -y ca-certificates java-11-openjdk-devel make gcc-c++ wget && \
  update-ca-trust extract && \
  set -eux; \
  \
  if [ "$HADOOP_FILE" == "_NOT_SET" ]; then \
    /tmp/asf_download.sh "hadoop.tar.gz" "hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz"; \
  else \
    mv "/tmp/$HADOOP_FILE" "hadoop.tar.gz"; \
  fi; \
  if [ "$ZOOKEEPER_FILE" == "_NOT_SET" ]; then \
    /tmp/asf_download.sh "zookeeper.tar.gz" "zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz"; \
  else \
    mv "/tmp/$ZOOKEEPER_FILE" "zookeeper.tar.gz"; \
  fi; \
  tar xzf hadoop.tar.gz -C /tmp/ && \
  tar xzf zookeeper.tar.gz -C /tmp/ && \
  mv /tmp/hadoop-$HADOOP_VERSION /opt/hadoop && \
  mv /tmp/apache-zookeeper-$ZOOKEEPER_VERSION-bin /opt/zookeeper && \
  rm -f hadoop.tar.gz zookeeper.tar.gz && \
  rm -rf /opt/hadoop/share/doc/hadoop

ARG ACCUMULO_VERSION=2.1.0 \
  ACCUMULO_FILE=_NOT_SET
# Copy a known file along with the optional files (that might not exist).
# The known file, along with '*' for the optional files allows the command
# to succeed even if the optional files do not exist. If we used an empty
# string for the optional files default value, then this command would copy
# the entire build context, which is not what we want.
COPY asf_download.sh ${ACCUMULO_FILE}* /tmp/

RUN set -eux; \
  \
  if [ "$ACCUMULO_FILE" == "_NOT_SET" ]; then \
    /tmp/asf_download.sh "accumulo.tar.gz" "accumulo/$ACCUMULO_VERSION/accumulo-$ACCUMULO_VERSION-bin.tar.gz"; \
  else \
    mv "/tmp/$ACCUMULO_FILE" "accumulo.tar.gz"; \
  fi && \
  rm /tmp/asf_download.sh && \
  tar xzf accumulo.tar.gz -C /tmp/ && \
  mv /tmp/accumulo-$ACCUMULO_VERSION*/ /opt/accumulo && \
  rm -f accumulo.tar.gz && \
  /opt/accumulo/bin/accumulo-util build-native

ADD properties/ /opt/accumulo/conf/

ARG HADOOP_USER_NAME=accumulo
ENV HADOOP_HOME=/opt/hadoop \
  HADOOP_USER_NAME=$HADOOP_USER_NAME \
  ZOOKEEPER_HOME=/opt/zookeeper \
  ACCUMULO_HOME=/opt/accumulo \
  PATH="$PATH:/opt/accumulo/bin"

ENTRYPOINT ["accumulo"]
CMD ["help"]

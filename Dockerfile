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


##
## Base image. Rocky Linux 9 with updates, JRE 11 headless, and updated CA certs.
##
FROM rockylinux:9 as base

RUN set -eux; \
  yum install -y ca-certificates java-11-openjdk-headless && \
  update-ca-trust extract && \
  yum clean all && \
  rm -rf /var/cache/yum

##
## Base image for building. Adds wget, JDK and make (for building Accumulo native libs).
##
FROM base as buildbase

RUN set -eux; \
  yum install -y java-11-openjdk-devel make gcc-c++ wget && \
  update-ca-trust extract

COPY download.sh /usr/local/bin/

##
## Hadoop image. Download/copy and extract the Hadoop installation.
##
FROM buildbase as hadoop

ARG HADOOP_VERSION=3.3.3 \
  HADOOP_FILE=_NOT_SET

# Copy a known file along with the optional files (that might not exist).
# The known file, along with '*' for the optional file allows the command
# to succeed even if the optional file does not exist. If we used an empty
# string for the optional file default value, then this command would copy
# the entire build context, which is not what we want.
COPY download.sh ${HADOOP_FILE}* /tmp/

RUN set -eux; \
  download.sh "${HADOOP_FILE}" "hadoop.tar.gz" "hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz"; \
  tar xzf hadoop.tar.gz -C /tmp/; \
  mv /tmp/hadoop-*/ /opt/hadoop; \
  rm -rf /opt/hadoop/share/doc/hadoop

##
## Zookeeper image. Download/copy and extract the Zookeeper installation.
##
FROM buildbase as zookeeper

ARG ZOOKEEPER_VERSION=3.8.0 \
  ZOOKEEPER_FILE=_NOT_SET
# Copy a known file along with the optional files (that might not exist).
# The known file, along with '*' for the optional file allows the command
# to succeed even if the optional file does not exist. If we used an empty
# string for the optional file default value, then this command would copy
# the entire build context, which is not what we want.
COPY download.sh ${ZOOKEEPER_FILE}* /tmp/

RUN set -eux; \
  download.sh "${ZOOKEEPER_FILE}" "zookeeper.tar.gz" "zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz"; \
  tar xzf zookeeper.tar.gz -C /tmp/; \
  mv /tmp/apache-zookeeper-*/ /opt/zookeeper

##
## Accumulo image. Download/copy and extract the Accumulo installation, build native libs, and copy in properties.
##
FROM buildbase as accumulo

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk

ARG ACCUMULO_VERSION=2.1.0 \
  ACCUMULO_FILE=_NOT_SET
# Copy a known file along with the optional files (that might not exist).
# The known file, along with '*' for the optional file allows the command
# to succeed even if the optional file does not exist. If we used an empty
# string for the optional file default value, then this command would copy
# the entire build context, which is not what we want.
COPY download.sh ${ACCUMULO_FILE}* /tmp/

RUN set -eux; \
  download.sh "${ACCUMULO_FILE}" "accumulo.tar.gz" "accumulo/$ACCUMULO_VERSION/accumulo-$ACCUMULO_VERSION-bin.tar.gz"; \
  tar xzf accumulo.tar.gz -C /tmp/; \
  mv /tmp/accumulo-*/ /opt/accumulo; \
  /opt/accumulo/bin/accumulo-util build-native

ADD properties/ /opt/accumulo/conf/

##
## Final image. Copy extracted/built installations for hadoop, zookeeper, and accumulo.
## Also set environment variables and entrypoint.
##
FROM base

ARG HADOOP_USER_NAME=accumulo
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk \
  HADOOP_HOME=/opt/hadoop \
  HADOOP_USER_NAME=$HADOOP_USER_NAME \
  ZOOKEEPER_HOME=/opt/zookeeper \
  ACCUMULO_HOME=/opt/accumulo \
  PATH="$PATH:/opt/accumulo/bin"

COPY --from=hadoop /opt/hadoop /opt/hadoop
COPY --from=zookeeper /opt/zookeeper /opt/zookeeper
COPY --from=accumulo /opt/accumulo /opt/accumulo

ENTRYPOINT ["accumulo"]
CMD ["help"]

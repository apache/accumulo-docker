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

FROM centos:7

RUN yum install -y java-1.8.0-openjdk-devel make gcc-c++
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk

ARG HADOOP_VERSION
ARG HADOOP_USER_NAME
ARG ZOOKEEPER_VERSION

ENV HADOOP_VERSION ${HADOOP_VERSION:-2.7.3}
ENV HADOOP_USER_NAME ${HADOOP_USER_NAME:-accumulo}
ENV ZOOKEEPER_VERSION ${ZOOKEEPER_VERSION:-3.4.9}
ENV ACCUMULO_VERSION 2.0.0-SNAPSHOT

RUN curl -sL http://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz | tar -xzC /tmp
RUN curl -sL http://archive.apache.org/dist/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar -xzC /tmp
#RUN curl -sL http://archive.apache.org/dist/accumulo/$ACCUMULO_VERSION/accumulo-$ACCUMULO_VERSION-bin.tar.gz | tar -xzC /tmp
# Comment out line above and remove line below when 2.0.0 is released
ADD ./accumulo-$ACCUMULO_VERSION-bin.tar.gz /tmp/

RUN mv /tmp/hadoop-$HADOOP_VERSION /opt/hadoop
RUN mv /tmp/zookeeper-$ZOOKEEPER_VERSION /opt/zookeeper
RUN mv /tmp/accumulo-$ACCUMULO_VERSION /opt/accumulo

RUN /opt/accumulo/bin/accumulo-util build-native

ADD ./accumulo-site.xml /opt/accumulo/conf
ADD ./log4j-service.properties /opt/accumulo/conf
ADD ./log4j-monitor.properties /opt/accumulo/conf

ENV HADOOP_PREFIX /opt/hadoop
ENV ZOOKEEPER_HOME /opt/zookeeper
ENV ACCUMULO_HOME /opt/accumulo
ENV PATH "$PATH:$ACCUMULO_HOME/bin"

ENTRYPOINT ["accumulo"]
CMD ["help"]

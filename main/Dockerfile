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

FROM accumulo_base

ARG ACCUMULO_FILE=files/accumulo.tar.gz


COPY $ACCUMULO_FILE  /tmp/

RUN ls -l /tmp/ &&\
  tar xzf /tmp/accumulo.tar.gz -C /tmp/ && \
  mv /tmp/accumulo-* /opt/accumulo && \
  /opt/accumulo/bin/accumulo-util build-native && \
# The below line is required for Accumulo 2.0 to work with ZK 3.5 & above.  This will not be needed for Accumulo 2.1
  sed -i 's/\${ZOOKEEPER_HOME}\/\*/\${ZOOKEEPER_HOME}\/\*\:\${ZOOKEEPER_HOME}\/lib\/\*/g' /opt/accumulo/conf/accumulo-env.sh

ADD properties/ /opt/accumulo/conf/

ENV ACCUMULO_HOME /opt/accumulo
ENV PATH "$PATH:$ACCUMULO_HOME/bin"

ENTRYPOINT ["accumulo"]
CMD ["help"]

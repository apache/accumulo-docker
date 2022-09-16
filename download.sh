set -eux;

ACCUMULO_VERSION="2.0.1"
HADOOP_VERSION="3.2.1"
ZOOKEEPER_VERSION="3.6.0"


APACHE_DIST_URLS="https://www.apache.org/dyn/closer.cgi?action=download&filename= https://www-us.apache.org/dist/ https://www.apache.org/dist/ https://archive.apache.org/dist/"


download() {
  local f="$1"; shift;
  local distFile="$1"; shift;
  local success=;
  local distUrl=;
  for distUrl in $APACHE_DIST_URLS; do
    if wget -nv -O "$f" "$distUrl$distFile"; then
      success=1;
      break;
    fi;
  done;
  [ -n "$success" ];
};


download "base/files/hadoop.tar.gz" "hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz"; \
download "base/files/zookeeper.tar.gz" "zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz"; \
download "base/files/accumulo.tar.gz" "accumulo/$ACCUMULO_VERSION/accumulo-$ACCUMULO_VERSION-bin.tar.gz"; \

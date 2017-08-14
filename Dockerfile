FROM biggis/hdfs:2.7.1

MAINTAINER wipatrick

ARG ACCUMULO_VERSION=1.7.3
ARG ZK_VERSION=3.4.9
ARG BUILD_DATE
ARG VCS_REF

LABEL eu.biggis-project.build-date=$BUILD_DATE \
      eu.biggis-project.license="MIT" \
      eu.biggis-project.name="BigGIS" \
      eu.biggis-project.url="http://biggis-project.eu/" \
      eu.biggis-project.vcs-ref=$VCS_REF \
      eu.biggis-project.vcs-type="Git" \
      eu.biggis-project.vcs-url="https://github.com/biggis-project/biggis-accumulo" \
      eu.biggis-project.environment="dev" \
      eu.biggis-project.version=$ACCUMULO_VERSION

ENV ACCUMULO_HOME=/opt/accumulo
ENV ACCUMULO_CONF_DIR=$ACCUMULO_HOME/conf
ENV ZOOKEEPER_HOME=/opt/zookeeper
ENV HADOOP_PREFIX=/opt/hadoop-2.7.1
ENV PATH=$ACCUMULO_HOME/bin:$ZOOKEEPER_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ACCUMULO_HOME/lib/native

RUN set -x && \
    apk --update add --virtual build-dependencies curl make libgcc gcc g++ musl=1.1.16-r13 musl-dev=1.1.16-r13 && \
    apk add --no-cache libxml2 libxml2-utils && \
    curl -sS http://mirror.synyx.de/apache/accumulo/$ACCUMULO_VERSION/accumulo-$ACCUMULO_VERSION-bin.tar.gz | tar -xzf - -C /opt && \
    curl -s http://ftp.fau.de/apache/zookeeper/zookeeper-$ZK_VERSION/zookeeper-$ZK_VERSION.tar.gz | tar -xzf - -C /opt && \
    mv /opt/accumulo-$ACCUMULO_VERSION /opt/accumulo && \
    mv /opt/zookeeper-$ZK_VERSION /opt/zookeeper && \
    sed -i -e "s#mktemp -d /tmp/accumulo-native.XXXX#mktemp -d /tmp/accumulo-native.XXXXXX#g" $ACCUMULO_HOME/bin/build_native_library.sh && \
    /bin/bash -c "$ACCUMULO_HOME/bin/build_native_library.sh" && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/*

COPY ./files /

CMD ["/sbin/start.sh"]

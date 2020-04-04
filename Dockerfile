FROM openjdk:8u212-jre-alpine AS builder

ARG KAFKA_RELEASE=https://www-us.apache.org/dist/kafka/2.4.1/kafka_2.12-2.4.1.tgz
ENV KAFKA_RELEASE=${KAFKA_RELEASE}

ADD ${KAFKA_RELEASE}      /tmp/kafka.tgz

# -- kafka connect - include JDBC connector support (MySQL/MariaDB JDBC driver)
ARG KAFKA_CONNECT_JDBC=https://packages.confluent.io/maven/io/confluent/kafka-connect-jdbc/5.4.0/kafka-connect-jdbc-5.4.0.jar
ARG MYSQL_CONNECTOR_JAVA_SOURCE=https://dev.mysql.com/get/Downloads/Connector-J
ARG MYSQL_CONNECTOR_JAVA=mysql-connector-java-8.0.19

RUN tar xzf /tmp/kafka.tgz -C /usr/local && cd /usr/local && mv kafka_2.12-2.4.1 kafka            && \
    cd /usr/local/kafka && mkdir plugins share && cd share                                        && \
    wget -qO- $MYSQL_CONNECTOR_JAVA_SOURCE/$MYSQL_CONNECTOR_JAVA.zip                               | \
    unzip -p - $MYSQL_CONNECTOR_JAVA/$MYSQL_CONNECTOR_JAVA.jar > $MYSQL_CONNECTOR_JAVA.jar        && \
    cd ../plugins && wget $KAFKA_CONNECT_JDBC && cd ../config                                     && \
    sed -i 's/#plugin.path=.*/plugin.path=\/usr\/local\/kafka\/plugins/' connect-standalone.properties && \
    rm -rf /usr/local/kafka/site-docs


FROM openjdk:8u212-jre-alpine

ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/download/v1.21.7.0/s6-overlay-amd64.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

RUN apk add --no-cache bash                       && \
    tar xzf /tmp/s6overlay.tar.gz -C /            && \
    cd /var/log && mkdir zookeeper connect kafka  && \
    chown nobody zookeeper connect kafka          && \
    adduser -D -h /usr/local/kafka -u 7001 kafka  && \
    rm /tmp/s6overlay.tar.gz

COPY --from=builder --chown=kafka:kafka /usr/local/kafka /usr/local/kafka
COPY ./cont-init.d /etc/cont-init.d/
COPY ./services.d  /etc/services.d/

ENTRYPOINT [ "/init" ]

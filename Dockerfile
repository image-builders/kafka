FROM openjdk:8u212-jre-alpine

ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/download/v1.21.7.0/s6-overlay-amd64.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

ARG KAFKA_RELEASE=https://www-us.apache.org/dist/kafka/2.3.1/kafka_2.12-2.3.1.tgz
ENV KAFKA_RELEASE=${KAFKA_RELEASE}

ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz
ADD ${KAFKA_RELEASE}      /tmp/kafka.tgz

RUN apk add --no-cache bash                                                            && \
    tar xzf /tmp/kafka.tgz -C /usr/local && cd /usr/local && mv kafka_2.12-2.3.1 kafka && \
    tar xzf /tmp/s6overlay.tar.gz -C / && rm /tmp/*.tar.gz /tmp/*.tgz                  && \
    adduser -D -h /usr/local/kafka -u 7001 kafka && chown -R kafka /usr/local/kafka    && \
    mkdir /var/log/zookeeper /var/log/kafka                                            && \
    chown nobody /var/log/zookeeper /var/log/kafka                                     && \
    rm -rf /usr/local/kafka/site-docs

COPY ./scripts /etc/services.d/

ENTRYPOINT [ "/init" ]

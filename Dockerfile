FROM ubuntu:focal
ARG TARGETPLATFORM
ARG TARGETARCH
ARG BIND_VERSION
ARG BUILD_DATE

LABEL build_version="${TARGETPLATFORM} - ${BUILD_DATE}"
MAINTAINER ninerealmlabs <ahgraber@ninerealmlabs.com>

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        bind9 \
        bind9-doc \
        dnsutils \
        nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
              /tmp/* \
              /var/tmp/*

# s6 overlay
COPY ./scripts/install-s6.sh /tmp/install-s6.sh
RUN chmod +x /tmp/install-s6.sh \
    && /tmp/install-s6.sh ${TARGETPLATFORM} \
    && rm -rf /tmp/*

# standard DNS ports
EXPOSE 53/udp 53/tcp 
# for RNDC (remote name daemon control)
EXPOSE 953/tcp  

RUN mkdir -p \
    /config \
    /defaults \
    /etc/bind \
    /var/cache/bind \
    /var/lib/bind

VOLUME /config/logs
VOLUME /config/bind

# # create initial user
# RUN groupmod -g 1000 users && \
#  useradd -u 911 -U -d /config -s /bin/false abc && \
#  usermod -G users abc

COPY root/ /

ENTRYPOINT [ "/init" ]

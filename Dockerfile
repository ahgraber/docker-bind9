FROM ubuntu:focal
ARG TARGETPLATFORM
ARG TARGETARCH
ARG BIND_VERSION
ARG BUILD_DATE

LABEL build_version="${TARGETPLATFORM} - ${BUILD_DATE}"
LABEL maintainer="ninerealmlabs <ahgraber@ninerealmlabs.com>"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        bind9 \
        bind9-doc \
        curl \
        dnsutils \
        gcc \
        libssl-dev \
        libffi-dev \
        nano \
        openssl \
        python3 \
        python3-pip \
        tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
              /tmp/* \
              /var/tmp/*

# s6 overlay
COPY ./scripts/install-s6.sh /tmp/install-s6.sh
RUN chmod +x /tmp/install-s6.sh \
    && /tmp/install-s6.sh ${TARGETPLATFORM} \
    && rm -rf /tmp/* \
              /root/.cache

# standard DNS ports
EXPOSE 53/udp 53/tcp 
# for RNDC (remote name daemon control)
EXPOSE 953/tcp  

RUN mkdir -p \
    /config/log \
    /config/bind \
    /defaults \
    /etc/bind \
    /var/cache/bind \
    /var/lib/bind
 
VOLUME /config/log
VOLUME /config/bind

# # create initial user
# RUN groupmod -g 1000 users && \
#  useradd -u 911 -U -d /config -s /bin/false abc && \
#  usermod -G users abc

COPY root/ /

ENTRYPOINT [ "/init" ]

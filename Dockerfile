FROM openjdk:8u212-jre-alpine3.9

ENV LANG=C.UTF-8
ARG CROMWELL_UID=1001
ARG CROMWELL_GID=1001

# Install cromwell dependencies
RUN apk add --no-cache \
    bash \
    openssh \
    tzdata \
  # Create "cromwell" user
  && addgroup -g ${CROMWELL_GID} cromwell \
  && adduser -D -s /bin/bash -h /cromwell -u ${CROMWELL_UID} -G cromwell -g "cromwell" cromwell \
  && cp /etc/profile /cromwell/.profile \
  # Create keys and data directories
  && mkdir -p /cromwell/.ssh && chmod 700 /cromwell/.ssh \
  && ssh-keygen -t rsa -f /cromwell/.ssh/id_rsa -q -N "" -b 4096 \
  #&& ssh-keygen -t dsa -f /cromwell/.ssh/id_dsa -q -N "" \
  #&& ssh-keygen -t ecdsa -f /cromwell/.ssh/id_ecdsa -q -N "" -b 521 \
  #&& ssh-keygen -t ed25519 -f /cromwell/.ssh/id_ed25519 -q -N "" \
  && mkdir -p /data \
  && chown -R cromwell:cromwell /cromwell /data

ARG CROMWELL_VERSION=51
ENV CROMWELL_VERSION=$CROMWELL_VERSION

# Install cromwell
RUN wget -q -O=/cromwell/cromwell-$CROMWELL_VERSION https://github.com/broadinstitute/cromwell/releases/download/$CROMWELL_VERSION/cromwell-$CROMWELL_VERSION.jar \
  && ln -sf cromwell-$CROMWELL_VERSION.jar cromwell.jar \
  && chown cromwell:cromwell /cromwell/cromwell*.jar

# Configure miscellanea
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
EXPOSE 8000/tcp
WORKDIR /data
USER cromwell

ENTRYPOINT ["/docker-entrypoint.sh"]

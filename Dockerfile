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
  # Create SSH RSA key pair and data directory
  && mkdir -p /cromwell/.ssh && chmod 700 /cromwell/.ssh \
  && ssh-keygen -t rsa -f /cromwell/.ssh/id_rsa -q -N "" -b 4096 \
  && mkdir -p /data \
  && chown -R cromwell:cromwell /cromwell /data

ARG CROMWELL_VERSION=51
ENV CROMWELL_VERSION=$CROMWELL_VERSION

# Install cromwell
RUN wget -q -O /cromwell/cromwell-$CROMWELL_VERSION.jar https://github.com/broadinstitute/cromwell/releases/download/$CROMWELL_VERSION/cromwell-$CROMWELL_VERSION.jar \
  && ln -sf /cromwell/cromwell-$CROMWELL_VERSION.jar /cromwell/cromwell.jar \
  && chown cromwell:cromwell /cromwell/cromwell*.jar

# Configure miscellanea
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
EXPOSE 8000/tcp
WORKDIR /data
USER cromwell

ENTRYPOINT ["/docker-entrypoint.sh"]

FROM openjdk:8u212-jre-alpine3.9

ENV LANG=C.UTF-8
ARG CROMWELL_UID=1001
ARG CROMWELL_GID=1001

# Install cromwell dependencies
RUN apk add --no-cache \
    bash \
    openssh \
    sudo \
    tzdata \
  # Create a user account "cromwell"
  && addgroup -g ${CROMWELL_GID} cromwell \
  && adduser -D -s /bin/bash -G cromwell -u ${CROMWELL_UID} cromwell \
  && cp /etc/profile /home/cromwell/.profile \
  && mkdir -p /home/cromwell/.ssh && chmod 700 /home/cromwell/.ssh \
  # Create a work directory
  && mkdir -p /data \
  && chown -R cromwell:cromwell /home/cromwell /data

ARG CROMWELL_VERSION=51
ENV CROMWELL_VERSION=$CROMWELL_VERSION

# Install cromwell
RUN mkdir -p /app && cd /app \
  && wget --quiet https://github.com/broadinstitute/cromwell/releases/download/$CROMWELL_VERSION/cromwell-$CROMWELL_VERSION.jar \
  && ln -sf cromwell-$CROMWELL_VERSION.jar cromwell.jar

# Configure miscellanea
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
EXPOSE 8000/tcp
WORKDIR /data
USER cromwell

ENTRYPOINT ["/docker-entrypoint.sh"]

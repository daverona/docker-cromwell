FROM openjdk:8u212-jre-alpine3.9

ENV LANG=C.UTF-8

# Install cromwell dependencies
RUN apk add --no-cache \
    bash \
    openssh \
    tzdata \
  # Change root's default shell to bash
  && sed -i "0s|/bin/ash|/bin/bash|" /etc/passwd \
  && cp /etc/profile /root/.profile \
  # Create directories
  && mkdir -p /root/.ssh && chmod 700 /root/.ssh \
  && mkdir -p /data

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

ENTRYPOINT ["/docker-entrypoint.sh"]

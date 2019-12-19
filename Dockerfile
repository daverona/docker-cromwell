FROM openjdk:8u212-jre-alpine3.9

ARG CROMWELL_VERSION=47
ARG CROMWELL_UID=503

# Set the system time zone
# @see https://wiki.alpinelinux.org/wiki/Setting_the_timezone
ARG APP_TIMEZONE=UTC
RUN apk add --no-cache tzdata \
  && cp "/usr/share/zoneinfo/$APP_TIMEZONE" /etc/localtime \
  && echo "$APP_TIMEZONE" > /etc/timezone

# Install cromwell
RUN mkdir -p /app && cd /app \
  && wget https://github.com/broadinstitute/cromwell/releases/download/$CROMWELL_VERSION/cromwell-$CROMWELL_VERSION.jar \
  && ln -sf cromwell-$CROMWELL_VERSION.jar cromwell.jar

# Create cromwell user and generate RSA key pair possibly used to authenticate
RUN apk add --no-cache \
    bash \
    openssh \
    gosu --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  && addgroup -g $CROMWELL_UID cromwell \
  && adduser -h /home/cromwell -s /bin/bash -G cromwell -u $CROMWELL_UID -D cromwell \
  && gosu cromwell ssh-keygen -b 4096 -t rsa -f /home/cromwell/.ssh/id_rsa -q -N "" \
  && mkdir -p /var/log/cromwell && chown cromwell:cromwell /var/log/cromwell

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
EXPOSE 8000/tcp
WORKDIR /var/local

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["cromwell", "server"]

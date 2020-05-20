FROM openjdk:8u212-jre-alpine3.9

ARG CROMWELL_VERSION=50

# Install cromwell
COPY conf/ /app/conf/
RUN wget --quiet --directory-prefix=/app https://github.com/broadinstitute/cromwell/releases/download/$CROMWELL_VERSION/cromwell-$CROMWELL_VERSION.jar \
  && cd /app && ln -sf cromwell-$CROMWELL_VERSION.jar cromwell.jar

ARG APP_TIMEZONE=UTC

# Install useful apps for HPC backends
RUN apk add --no-cache \
    bash \
#    gosu --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    openssh \
    tzdata \
  # Configure SSH user account (root) for HPC backends
  && ssh-keygen -b 4096 -t rsa -f /root/.ssh/id_rsa -q -N "" \
  && cp /etc/profile /root/.profile \
  && sed -i "0s|/bin/ash|/bin/bash|" /etc/passwd \
  # Set the system time zone
  && cp "/usr/share/zoneinfo/$APP_TIMEZONE" /etc/localtime \
  && echo "$APP_TIMEZONE" > /etc/timezone

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
EXPOSE 8000/tcp
WORKDIR /var/local

ENV CROMWELL_VERSION=$CROMWELL_VERSION

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["cromwell"]

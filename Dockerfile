FROM openjdk:8u212-jre-alpine3.9

ARG APP_TIMEZONE=UTC
ENV LANG=C.UTF-8

# Install cromwell helpers
RUN apk add --no-cache \
    bash \
    # gosu --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    openssh \
    tzdata \
  # Set the system time zone
  && cp "/usr/share/zoneinfo/$APP_TIMEZONE" /etc/localtime \
  && echo "$APP_TIMEZONE" > /etc/timezone \
  # Change the default shell
  && sed -i "0s|/bin/ash|/bin/bash|" /etc/passwd \
  && cp /etc/profile /root/.profile

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
WORKDIR /var/local

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["cromwell"]

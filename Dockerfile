FROM openjdk:8u212-jre-alpine3.9

ARG CROMWELL_VERSION=50
ARG APP_TIMEZONE=UTC

# Install cromwell and dependencies
RUN apk add --no-cache \
    bash \
#    gosu --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    openssh \
    tzdata \
  && mkdir -p /app && cd /app \
  && wget --quiet https://github.com/broadinstitute/cromwell/releases/download/$CROMWELL_VERSION/cromwell-$CROMWELL_VERSION.jar \
  && ln -sf cromwell-$CROMWELL_VERSION.jar cromwell.jar \
  && cp "/usr/share/zoneinfo/$APP_TIMEZONE" /etc/localtime \
  && echo "$APP_TIMEZONE" > /etc/timezone \
  && ssh-keygen -b 4096 -t rsa -f /root/.ssh/id_rsa -q -N ""

ENV CROMWELL_VERSION=$CROMWELL_VERSION

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
EXPOSE 8000/tcp
WORKDIR /var/local

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["cromwell"]

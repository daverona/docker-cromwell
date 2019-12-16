FROM openjdk:8u212-jre-alpine3.9

ARG CROMWELL_VERSION=47

# Setting the system timezone
# @see https://wiki.alpinelinux.org/wiki/Setting_the_timezone
ARG APP_TIMEZONE=UTC
RUN apk add --no-cache tzdata \
  && cp "/usr/share/zoneinfo/$APP_TIMEZONE" /etc/localtime \
  && echo "$APP_TIMEZONE" > /etc/timezone

RUN apk add --no-cache bash docker

RUN mkdir -p /app && cd /app \
  && wget https://github.com/broadinstitute/cromwell/releases/download/$CROMWELL_VERSION/cromwell-$CROMWELL_VERSION.jar \
  && ln -sf cromwell-$CROMWELL_VERSION.jar cromwell.jar \
  && mkdir -p /var/log/cromwell

WORKDIR /var/local
EXPOSE 8000/tcp

ENTRYPOINT ["/bin/bash", "-c", "/usr/bin/java ${JAVA_OPTS} -jar /app/cromwell.jar ${CROMWELL_ARGS} ${*}", "--"]

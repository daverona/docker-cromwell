FROM openjdk:8u212-jre-alpine3.9

# Install cromwell dependencies
RUN apk add --no-cache \
    bash \
    gosu --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    openssh \
    tzdata

ARG CROMWELL_VERSION=47
ARG APP_TIMEZONE=UTC
ARG CROMWELL_UID=501

# Install cromwell
RUN cp "/usr/share/zoneinfo/$APP_TIMEZONE" /etc/localtime \
  && echo "$APP_TIMEZONE" > /etc/timezone \
  # Create user and group for cromwell
  && addgroup -g $CROMWELL_UID cromwell \
  && adduser -h /home/cromwell -s /bin/bash -G cromwell -u $CROMWELL_UID -D cromwell \
  # Generate cromwell's SSH key pair 
  && gosu cromwell ssh-keygen -b 4096 -t rsa -f /home/cromwell/.ssh/id_rsa -q -N "" \
  # Install cromwell
  && mkdir -p /app && cd /app \
  && wget --quiet https://github.com/broadinstitute/cromwell/releases/download/$CROMWELL_VERSION/cromwell-$CROMWELL_VERSION.jar \
  && ln -sf cromwell-$CROMWELL_VERSION.jar cromwell.jar

#COPY docker-entrypoint.sh /
#RUN chmod +x /docker-entrypoint.sh
EXPOSE 8000/tcp
WORKDIR /var/local

#ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["cromwell", "server"]
USER cromwell
CMD ["java", "${JAVA_OPTS}", "-jar", "/app/cromwell.jar", "${CROMWELL_ARGS}"]


FROM openjdk:8u212-jre-alpine3.9

ARG CROMWELL_VERSION=58
ARG WOMTOOL_VERSION=58
ENV CROMWELL_VERSION=${CROMWELL_VERSION}
ENV WOMTOOL_VERSION=${WOMTOOL_VERSION}
ENV LANG=C.UTF-8

# Install cromwell
RUN apk add --no-cache \
    bash \
    gosu --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
    openssh \
    tzdata \
  # Create SSH RSA key pair and data directory
  && mkdir -p /home/cromwell/.ssh && chmod 700 /home/cromwell/.ssh \
  && ssh-keygen -t rsa -f /home/cromwell/.ssh/id_rsa -q -N "" -b 4096 \
  && cp /etc/profile /home/cromwell/.profile \
  && mkdir -p /usr/local/java && cd /usr/local/java \
  && wget -q "https://github.com/broadinstitute/cromwell/releases/download/${CROMWELL_VERSION}/cromwell-${CROMWELL_VERSION}.jar" \
  && wget -q "https://github.com/broadinstitute/cromwell/releases/download/${CROMWELL_VERSION}/womtool-${WOMTOOL_VERSION}.jar" \
  && ln -sf "cromwell-${CROMWELL_VERSION}.jar" cromwell.jar \
  && ln -sf "womtool-${WOMTOOL_VERSION}.jar" womtool.jar

# Configure miscellanea
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
EXPOSE 8000/tcp
WORKDIR /var/local

ENTRYPOINT ["/docker-entrypoint.sh"]

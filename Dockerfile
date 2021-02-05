FROM openjdk:8u212-jre-alpine3.9

ENV LANG=C.UTF-8

# Install cromwell dependencies
RUN apk add --no-cache \
    bash \
    gosu --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
    openssh \
    tzdata \
  # Create SSH RSA key pair and data directory
  && mkdir -p /home/cromwell/.ssh && chmod 700 /home/cromwell/.ssh \
  && ssh-keygen -t rsa -f /home/cromwell/.ssh/id_rsa -q -N "" -b 4096 \
  && cp /etc/profile /home/cromwell/.profile \
  && mkdir -p /data

ARG CROMWELL_VERSION=52
ENV CROMWELL_VERSION=$CROMWELL_VERSION

# Install cromwell
RUN wget -q -O "/home/cromwell/cromwell-${CROMWELL_VERSION}.jar" \
    "https://github.com/broadinstitute/cromwell/releases/download/${CROMWELL_VERSION}/cromwell-${CROMWELL_VERSION}.jar"

# Configure miscellanea
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
EXPOSE 8000/tcp
WORKDIR /data

ENTRYPOINT ["/docker-entrypoint.sh"]

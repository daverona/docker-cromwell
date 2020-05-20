#!/bin/bash
set -e

# Set the system time zone
if [ ! -z "$APP_TIMEZONE" ]; then
  cp "/usr/share/zoneinfo/$APP_TIMEZONE" /etc/localtime
  echo "$APP_TIMEZONE" > /etc/timezone
fi

if [ "cromwell" == "$1" ]; then
  # Scan each host listed in /app/hosts to add host keys for HPC backends
  hosts=/app/hosts
  if [ -f "$hosts" ]; then
    while read host; do
      host=${host//[[:space:]]/}
      [ ! -z "$host" ] && ssh-keyscan -H $host >> /root/.ssh/known_hosts
    done < $hosts
  fi

  # Start cromwell (in server mode by default)
  echo "Received: JAVA_OPTS=${JAVA_OPTS}"
  echo "Received: CROMWELL_ARGS=${CROMWELL_ARGS}"
  echo "Received: \$@=$@"
  shift
  [ -z "$*" ] && [ -z "${CROMWELL_ARGS}" ] && CROMWELL_ARGS=server
  echo "Executing: java ${JAVA_OPTS} -jar /app/cromwell-$CROMWELL_VERSION.jar ${CROMWELL_ARGS} $@"
  echo "--"
  exec java ${JAVA_OPTS} -jar /app/cromwell-$CROMWELL_VERSION.jar ${CROMWELL_ARGS} "$@"
fi

exec "$@"

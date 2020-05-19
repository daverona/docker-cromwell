#!/bin/bash
set -e

if [ "cromwell" == "$1" ]; then
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

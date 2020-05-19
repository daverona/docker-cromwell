#!/bin/bash
set -e

if [ "cromwell" == "$1" ]; then
  echo "JAVA_OPTS=${JAVA_OPTS}"
  echo "CROMWELL_ARGS=${CROMWELL_ARGS}"
  echo "\$@=$@"
  shift
  [ -z "$*" ] && [ -z "${CROMWELL_ARGS}" ] && CROMWELL_ARGS=server
  exec java ${JAVA_OPTS} -jar /app/cromwell.jar ${CROMWELL_ARGS} "$@"
fi

exec "$@"

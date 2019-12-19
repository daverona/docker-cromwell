#!/bin/bash
set -e

if [ "cromwell" == "$(basename $1)" ]; then
  shift
  exec gosu cromwell /usr/bin/java ${JAVA_OPTS} -jar /app/cromwell.jar ${CROMWELL_ARGS} "$@"
fi

exec "$@"

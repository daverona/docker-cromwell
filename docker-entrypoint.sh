#!/bin/bash
set -e

if [ "cromwell" == "$(basename $1)" ]; then
  exec gosu cromwell /bin/bash -c 'java ${JAVA_OPTS} -jar /app/cromwell.jar ${CROMWELL_ARGS} "$@" | tee -a /var/log/cromwell/cromwell.log' "$@"
fi

exec "$@"

#!/bin/bash
set -e

if [ "cromwell" == "$(basename $1)" ]; then
  exec dumb-init gosu cromwell /bin/bash -c 'java ${JAVA_OPTS} -jar /app/cromwell.jar ${CROMWELL_ARGS} "$@" 2<&1 | tee -a /var/log/cromwell/cromwell.log' "$@"
fi

exec "$@"

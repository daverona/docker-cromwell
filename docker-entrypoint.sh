#!/bin/bash
set -e

#trap "exit 1" TERM INT PIPE EXIT

if [ "cromwell" == "$(basename $1)" ]; then
  exec gosu cromwell /bin/bash -c 'java ${JAVA_OPTS} -jar /app/cromwell.jar ${CROMWELL_ARGS} "$@" 2<&1 | tee -a /var/log/cromwell/cromwell.log' "$@"
fi

exec "$@"

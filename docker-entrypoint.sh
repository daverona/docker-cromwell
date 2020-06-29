#!/bin/bash
set -e

if [ $# -eq 0 ] || [ "java" == "$(basename $1)" ]; then
  red='\033[1;31m'
  cyan='\033[1;36m'
  reset='\033[0m'

  # Start cromwell (in server mode by default)
  if [ $# -eq 0 ]; then
    [ -z "$*" ] && [ -z "${CROMWELL_ARGS}" ] && CROMWELL_ARGS=server
    echo -e "${cyan}Running \"java ${JAVA_OPTS} -jar /app/cromwell-${CROMWELL_VERSION}.jar ${CROMWELL_ARGS} $@\"...${reset}"
    exec java ${JAVA_OPTS} -jar /app/cromwell-${CROMWELL_VERSION}.jar ${CROMWELL_ARGS} "$@"
  fi
fi

exec "$@"

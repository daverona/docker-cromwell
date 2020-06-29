#!/bin/bash
set -e

if [ $# -eq 0 ] || [ "java" == "$(basename $1)" ]; then
  red='\033[1;31m'
  cyan='\033[1;36m'
  reset='\033[0m'

  # Make sure that cromwell has what he needs
  # sudo chown cromwell:cromwell "${PWD}"

  ([ -z "${CROMWELL_KEYNAME}" ] || [ -z "${CROMWELL_PRIVKEY}" ]) \
  && echo -e "${red}CROMWELL_KEYNAME and/or CROMWELL_PRIVKEY are not given!${reset}"

  # Create private key from environment variable
  if [ ! -z "${CROMWELL_KEYNAME}" ] && [ ! -z "${CROMWELL_PRIVKEY}" ]; then
    echo "${CROMWELL_PRIVKEY}" > "/root/.ssh/${CROMWELL_KEYNAME}"
    chmod 600 "/root/.ssh/${CROMWELL_KEYNAME}"
    unset CROMWELL_KEYFILE
    unset CROMWELL_PRIVKEY
  fi

  # Start cromwell (in server mode by default)
  if [ $# -eq 0 ]; then
    [ -z "$*" ] && [ -z "${CROMWELL_ARGS}" ] && CROMWELL_ARGS=server
    echo -e "${cyan}Running \"java ${JAVA_OPTS} -jar /app/cromwell-${CROMWELL_VERSION}.jar ${CROMWELL_ARGS} $@\"...${reset}"
    exec java ${JAVA_OPTS} -jar /app/cromwell-${CROMWELL_VERSION}.jar ${CROMWELL_ARGS} "$@"
  fi
fi

exec "$@"

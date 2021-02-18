#!/bin/bash

gosuer=()
color_cyan='\033[1;36m'
color_red='\033[1;31m'
color_reset='\033[0m'

# Create cromwell account if CROMWELL_UID is specified

[ -z "${CROMWELL_GID}" ] && [ ! -z "${CROMWELL_UID}" ] && CROMWELL_GID=${CROMWELL_UID}
if [ ! -z "${CROMWELL_GID}" ] && [ ! -z "${CROMWELL_UID}" ]; then
  group="$(getent group "${CROMWELL_GID}" | cut -d: -f1)"
  if [ "${group}" != "" ]; then
    echo -e "${color_red}gid(${CROMWELL_GID}) is taken by \"${group}\" in the container.${color_reset}"
  else
    addgroup -g ${CROMWELL_GID} cromwell
  fi

  user="$(getent passwd "${CROMWELL_UID}" | cut -d: -f1)"
  if [ "${user}" != "" ]; then
    echo -e "${color_red}uid(${CROMWELL_UID}) is taken by \"${user}\" in the container.${color_reset}"
  else
    adduser -D -s /bin/bash -h /home/cromwell -u ${CROMWELL_UID} -G cromwell -g "cromwell" cromwell
  fi

  gosuer=(gosu cromwell:cromwell)
  chown -R cromwell:cromwell /home/cromwell
  chown cromwell:cromwell /data ${PWD}
  echo "Created cromwell account: uid=${CROMWELL_UID}, gid=${CROMWELL_GID}"
fi

set -e

# Run cromwell.jar if command is not specified

if [ $# -eq 0 ]; then
  [ -z "$*" ] && [ -z "${CROMWELL_ARGS}" ] && CROMWELL_ARGS=server
  echo "Make sure that uid=${CROMWELL_UID:-$(id -u)}, gid=${CROMWELL_GID:-$(id -g)} on the host can read and write \"cromwell execution\" and \"workflow log\" directories in the container."
  echo -e "${color_cyan}Executing \"java ${JAVA_OPTS} -jar /home/cromwell/cromwell-${CROMWELL_VERSION}.jar ${CROMWELL_ARGS} $@\"...${color_reset}"
  exec "${gosuer[@]}" java ${JAVA_OPTS} -jar "/home/cromwell/cromwell-${CROMWELL_VERSION}.jar" ${CROMWELL_ARGS} "$@"
fi

exec "${gosuer[@]}" "$@"

#!/bin/bash
set -e

if [ $# -eq 0 ] || [ "java" == "$(basename $1)" ]; then
  red='\033[1;31m'
  cyan='\033[1;36m'
  reset='\033[0m'

  # Scan and add /etc/hosts to known hosts
  #etc_hosts=$(sed -e 's/#.*//' -e 's/[[:blank:]]*$//' -e '/^$/d' -e 's/[[:blank:]][[:blank:]]*/ /' /etc/hosts)
  #ssh-keyscan -H $etc_hosts 2>/dev/null >> /root/.ssh/known_hosts

  # Scan and add given hosts to known hosts
  #[ ! -z "${EXTERNAL_HOSTS}" ] && ssh-keyscan -H ${EXTERNAL_HOSTS//,/ } 2>/dev/null >> /root/.ssh/known_hosts

  # Remove duplicated hosts
  #temp=`mktemp`
  #sort /root/.ssh/known_hosts | uniq > temp
  #rm -rf /root/.ssh/known_hosts && mv temp /root/.ssh/known_hosts

  # Create SSH key pairs (needed for remote login)
  #[ ! -f "/root/.ssh/id_rsa" ] && ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -N "" -b 4096 
  #[ ! -f "/root/.ssh/id_dsa" ] && ssh-keygen -t dsa -f /root/.ssh/id_dsa -q -N ""
  #[ ! -f "/root/.ssh/id_ecdsa" ] && ssh-keygen -t ecdsa -f /root/.ssh/id_ecdsa -q -N "" -b 521
  #[ ! -f "/root/.ssh/id_ed25519" ] && ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -q -N ""

  # Make sure that user cromwell has what he needs
  #chown -R cromwell:cromwell /home/cromwell /data
  #mkdir -p /home/cromwell/.ssh /data
  #chmod 700 /home/cromwell/.ssh

  ([ -z "${CROMWELL_KEYNAME}" ] || [ -z "${CROMWELL_PRIVKEY}" ]) \
  && echo -e "${red}CROMWELL_KEYNAME and/or CROMWELL_PRIVKEY are not given!${reset}"

  # Create private key from environment variable
  if [ ! -z "${CROMWELL_KEYNAME}" ] && [ ! -z "${CROMWELL_PRIVKEY}" ]; then
    echo "${CROMWELL_PRIVKEY}" > "/home/cromwell/.ssh/${CROMWELL_KEYNAME}"
    chmod 600 "/home/cromwell/.ssh/${CROMWELL_KEYNAME}"
    unset CROMWLL_PRIVKEY
  fi

  # Start cromwell (in server mode by default)
  if [ $# -eq 0 ]; then
    [ -z "$*" ] && [ -z "${CROMWELL_ARGS}" ] && CROMWELL_ARGS=server
    echo -e "${cyan}Running \"java ${JAVA_OPTS} -jar /app/cromwell-${CROMWELL_VERSION}.jar ${CROMWELL_ARGS} $@\"...${reset}"
    exec java ${JAVA_OPTS} -jar /app/cromwell-${CROMWELL_VERSION}.jar ${CROMWELL_ARGS} "$@"
  fi
fi

exec "$@"

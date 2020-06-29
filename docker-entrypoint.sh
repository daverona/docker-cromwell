#!/bin/bash
set -e

if [ "cromwell" == "$1" ]; then
  # Make sure no one can read /root/.ssh 
  mkdir -p /root/.ssh && chmod 700 /root/.ssh

  # Scan and add /etc/hosts to known hosts
  etc_hosts=$(sed -e 's/#.*//' -e 's/[[:blank:]]*$//' -e '/^$/d' -e 's/[[:blank:]][[:blank:]]*/ /' /etc/hosts)
  ssh-keyscan -H $etc_hosts 2>/dev/null >> /root/.ssh/known_hosts

  # Scan and add given hosts to known hosts
  [ ! -z "${EXTERNAL_HOSTS}" ] && ssh-keyscan -H ${EXTERNAL_HOSTS//,/ } 2>/dev/null >> /root/.ssh/known_hosts

  # Remove duplicated hosts
  temp=`mktemp`
  sort /root/.ssh/known_hosts | uniq > temp
  rm -rf /root/.ssh/known_hosts && mv temp /root/.ssh/known_hosts

  # Create SSH key pairs (needed for remote login)
  [ ! -f "/root/.ssh/id_rsa" ] && ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -N "" -b 4096 
  [ ! -f "/root/.ssh/id_dsa" ] && ssh-keygen -t dsa -f /root/.ssh/id_dsa -q -N ""
  [ ! -f "/root/.ssh/id_ecdsa" ] && ssh-keygen -t ecdsa -f /root/.ssh/id_ecdsa -q -N "" -b 521
  [ ! -f "/root/.ssh/id_ed25519" ] && ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -q -N ""

  # Start cromwell (in server mode by default)
  shift
  [ -z "$*" ] && [ -z "${CROMWELL_ARGS}" ] && CROMWELL_ARGS=server
  echo "Executing: java ${JAVA_OPTS} -jar /app/cromwell-${CROMWELL_VERSION}.jar ${CROMWELL_ARGS} \"$@\""
  exec java ${JAVA_OPTS} -jar /app/cromwell-${CROMWELL_VERSION}.jar ${CROMWELL_ARGS} "$@"
fi

exec "$@"

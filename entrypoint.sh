#!/bin/sh

export CONFIG_FILE=${CONFIG_FILE-"/home/step/config/ca.json"}
export PASSWORD_FILE=${PASSWORD_FILE-"/home/step/secrets/password"}
export PASSWORD=${PASSWORD-"password"}

if [ ! -f "${PASSWORD_FILE}" ]; then
  mkdir -p $(dirname $PASSWORD_FILE)
  echo $PASSWORD > $PASSWORD_FILE
fi

if [ -f "${CONFIG_FILE}" ]; then
  echo "Using existing configuration file"
else
  echo "No configuration file found at ${CONFIG_FILE}"

  /usr/local/bin/step ca init --name "Fake Authority" --provisioner admin --dns "ca.internal" --address ":443" --password-file=${PASSWORD_FILE}

  /usr/local/bin/step ca provisioner add development --type ACME

  # Increase certificate validity period
  echo $(cat config/ca.json | jq '.authority.provisioners[[.authority.provisioners[] | .name=="development"] | index(true)].claims |= (. + {"maxTLSCertDuration":"2160h","defaultTLSCertDuration":"720h"})') > config/ca.json
fi

exec "$@"

#!/bin/sh

export CONFIG_FILE=${CONFIG_FILE-"/home/step/config/ca.json"}
export PASSWORD_FILE=${PASSWORD_FILE-"/home/step/secrets/password"}

if [ -f "${CONFIG_FILE}" ]; then
  echo "Using existing configuration file"
else
  echo "No configuration file found at ${CONFIG_FILE}"

  /usr/local/bin/step ca init --name "Fake Authority" --provisioner admin --dns "ca.internal" --address ":443" --password-file=${PASSWORD_FILE}

  /usr/local/bin/step ca provisioner add development --type ACME
fi

exec "$@"

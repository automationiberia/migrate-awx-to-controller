#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "usage: ${0} <tag>"
  exit 1
fi

AAH=quay.io/automationiberia/casc

ansible-builder build -v3 --tag ${AAH}/${1}
podman push ${AAH}/${1} --tls-verify=false

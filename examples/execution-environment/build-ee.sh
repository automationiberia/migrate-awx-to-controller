#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "usage: ${0} <tag>"
  exit 1
fi

AAH=satellite.bcnconsulting.com/red_ribbon/application_images/aap

ansible-builder build -v3 --tag ${AAH}_${1}
podman push ${AAH}_${1} --tls-verify=false

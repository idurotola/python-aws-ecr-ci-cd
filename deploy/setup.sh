#!/bin/bash

set -e
set -u
set -o pipefail

apk add --no-cache py-pip=9.0.0-r1
apk add --update  --no-cache curl
pip install docker-compose==1.12.0 
pip install awscli==1.11.76

curl -L -o ~/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5rc1/jq-linux-x86_64-static && chmod +x ~/bin/jq
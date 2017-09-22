#!/bin/bash

set -e
set -u
set -o pipefail

apk add --no-cache py-pip=9.0.0-r1
apk add --update  --no-cache curl curl-dev
pip install docker-compose==1.12.0 
pip install awscli==1.11.76
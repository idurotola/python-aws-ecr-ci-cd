#!/bin/bash

set -e
set -u
set -o pipefail

apk add --no-cache py-pip=9.0.0-r1
pip install docker-compose==1.12.0 
pip install awscli==1.11.76
tar -zxvf pycurl-7.10.5.tar.gz
cd pycurl-7.10.5
python setup.py install

curl -L -o ~/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5rc1/jq-linux-x86_64-static && chmod +x ~/bin/jq
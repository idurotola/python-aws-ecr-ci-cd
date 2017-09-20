#!/bin/bash

# Exit on any error
set -e

# Install aws on this machine
pip install awscli --upgrade
apt-get install jq
echo 'aws should be installed now'
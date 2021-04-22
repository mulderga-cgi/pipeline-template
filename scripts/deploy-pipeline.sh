#!/usr/bin/env bash

set -e -o pipefail -x

PIPELINE_FILE=${PIPELINE_FILE:-pipeline-source/pipeline-microservice-am2.yml}

echo "Deploying pipeline for ${PIPELINE_NAME} with pipeline ${PIPELINE_FILE}"

./pipeline-source/scripts/login-ci.sh
./pipeline-source/scripts/decrypt.sh pipeline-source

FLY_PARAMS="-p ${PIPELINE_NAME} -c ${PIPELINE_FILE} -l pipeline-source/credentials.yml"

# If we deploy an application pipeline we have an app.yml file in the app-ci-source folder
if [ -d "app-ci-source" ]; then
  FLY_PARAMS="${FLY_PARAMS} -l pipeline-source/app-defaults.yml -l app-ci-source/ci/app.yml"
fi

fly -t ci set-pipeline --non-interactive ${FLY_PARAMS} >fly-output

cat fly-output |
  sed -E "s/(.*([Kk][Ee][Yy]|[Pp][Aa][Ss]+)[^:]*).*/\1: **hidden**/" |
  sed -E "s/(.*[Tt][Oo][Kk][Ee][Nn][^:]*).*/\1: **hidden**/" |
  sed -E "s/(.*):.*https?:\/\/hooks\.slack\.com.*/\1: **hidden**/"

rm -f fly-output

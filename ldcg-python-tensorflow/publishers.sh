#!/bin/bash

set -ex

if [ $JOB_NAME == 'ldcg-python-tensorflow-nightly' ]; then
  OUTPUT_PATH="ldcg/python/tensorflow-nightly/${BUILD_NUMBER}/"
else
  OUTPUT_PATH="ldcg/python/tensorflow/$(date -u +%Y%m%d)/"
fi

if [ -e /etc/debian_version ]; then
  BUILD_NUMBER="${BUILD_NUMBER}-debian"
else
   sudo dnf install -y python3-requests wget
fi

ls -alR /var/tmp/workspace/out

# Publish wheel files
test -d ${HOME}/bin || mkdir ${HOME}/bin
wget -q https://git.linaro.org/ci/publishing-api.git/blob_plain/HEAD:/linaro-cp.py -O ${HOME}/bin/linaro-cp.py
time python3 ${HOME}/bin/linaro-cp.py \
  --server ${PUBLISH_SERVER} \
  --link-latest \
  /home/buildslave/wheels \
  $OUTPUT_PATH

set +x

echo "Python wheels: https://snapshots.linaro.org/$OUTPUT_PATH"
#!/bin/bash

set -ex

[ -z "${KSELFTEST_SKIPLIST}" ] && export KSELFTEST_SKIPLIST=""

if [ ! -z "${KERNEL_DESCRIBE}" ]; then
    export QA_BUILD_VERSION=${KERNEL_DESCRIBE}
else
    export QA_BUILD_VERSION=${KERNEL_COMMIT:0:12}
fi

rm -rf configs
git clone --depth 1 http://git.linaro.org/ci/job/configs.git

# Pre install jinja2-cli
# Create LTP sub test suite templates
LTP_TESTS="cap_bounds commands containers fcntl-locktests filecaps fs fs_bind fs_perms_simple fsx hugetlb io ipc math nptl pty sched securebits syscalls timers"
[ -z "${DEVICE_TYPE}" ] || \
for ltptest in ${LTP_TESTS}; do
    ${HOME}/.local/bin/jinja2 -D testname=${ltptest} configs/openembedded-lkft/lava-job-definitions/${DEVICE_TYPE}/master-template-ltp.yaml.jinja2 > configs/openembedded-lkft/lava-job-definitions/${DEVICE_TYPE}/template-ltp-${ltptest}.yaml
    LTP_TEMPLATES="${LTP_TEMPLATES} template-ltp-${ltptest}.yaml"
done

[ -z "${DEVICE_TYPE}" ] || \
python configs/openembedded-lkft/submit_for_testing.py \
  --device-type ${DEVICE_TYPE} \
  --build-number ${BUILD_NUMBER} \
  --lava-server ${LAVA_SERVER} \
  --qa-server ${QA_SERVER} \
  --qa-server-team lkft \
  --qa-server-project ${QA_SERVER_PROJECT} \
  --git-commit ${QA_BUILD_VERSION} \
  --template-names template-kselftest.yaml template-libhugetlbfs.yaml ${LTP_TEMPLATES}

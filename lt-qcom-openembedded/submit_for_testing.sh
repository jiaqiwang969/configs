#!/bin/bash

rm -rf configs
git clone --depth 1 http://git.linaro.org/ci/job/configs.git

# Install jinja2-cli and ruamel.yaml, required by submit_for_testing.py
pip install --user --force-reinstall jinja2-cli ruamel.yaml

# main parameters
export DEPLOY_OS=oe
export OS_INFO=openembedded-${DISTRO}-${MANIFEST_BRANCH}

# boot and rootfs parameters, BOOT_URL comes from builders.sh
# and has not compression
export BOOT_URL_COMP=
export LXC_BOOT_FILE=$(basename ${BOOT_URL})

export RESIZE_ROOTFS=

# Tests settings, thermal fails in db410c
export GST_IGNORE_TESTS_REPO="https://git.linaro.org/landing-teams/working/qualcomm/configs.git"
if [ "${DEVICE_TYPE}" = "dragonboard-410c" ]; then
    export PM_QA_TESTS="cpufreq cpuidle cpuhotplug cputopology"
    export GST_IGNORE_TESTS_FILE="qa/gst-validate/db410c.ignore"
elif [ "${DEVICE_TYPE}" = "dragonboard-820c" ]; then
    export PM_QA_TESTS="cpufreq cputopology"
    export GST_IGNORE_TESTS_FILE="qa/gst-validate/db820c.ignore"
else
    export PM_QA_TESTS="cpufreq cpuidle cpuhotplug thermal cputopology"
fi
export SMOKE_TESTS="pwd, uname -a, ip a, vmstat, lsblk"
export PTEST_EXCLUDE="bluez5 libxml2 parted python strace"

case "${MACHINE}" in
  dragonboard-410c|dragonboard-820c)
    export DEVICE_TYPE="${MACHINE}"
    if [ ${DEVICE_TYPE} = "dragonboard-410c" ]; then
      export BOOT_OS_PROMPT=\'root@dragonboard-410c:~#\'
    elif [ ${DEVICE_TYPE} = "dragonboard-820c" ]; then
      export BOOT_OS_PROMPT=\'root@dragonboard-820c:~#\'
    fi

    case "${DISTRO}" in
      rpb)
        export ROOTFS_URL=${ROOTFS_SPARSE_BUILD_URL}
        export ROOTFS_URL_COMP="gz"
        export LXC_ROOTFS_FILE=$(basename ${ROOTFS_URL} .gz)
        python configs/openembedded-lkft/submit_for_testing.py \
            --device-type ${DEVICE_TYPE} \
            --build-number ${BUILD_NUMBER} \
            --lava-server ${LAVA_SERVER} \
            --qa-server ${QA_SERVER} \
            --qa-server-team qcomlt \
            --qa-server-project openembedded-rpb-${MANIFEST_BRANCH} \
            --env-suffix="-${DISTRO}" \
            --git-commit ${BUILD_NUMBER} \
            --template-path configs/lt-qcom/lava-job-definitions \
            --template-base-pre base_template.yaml \
            --template-names template.yaml template-wifi.yaml template-bt.yaml template-ptest.yaml

        export ROOTFS_URL=${ROOTFS_DESKTOP_SPARSE_BUILD_URL}
        export ROOTFS_URL_COMP="gz"
        export LXC_ROOTFS_FILE=$(basename ${ROOTFS_URL} .gz)
        python configs/openembedded-lkft/submit_for_testing.py \
            --device-type ${DEVICE_TYPE} \
            --build-number ${BUILD_NUMBER} \
            --lava-server ${LAVA_SERVER} \
            --qa-server ${QA_SERVER} \
            --qa-server-team qcomlt \
            --qa-server-project openembedded-rpb-${MANIFEST_BRANCH} \
            --env-suffix="-${DISTRO}" \
            --git-commit ${BUILD_NUMBER} \
            --template-path configs/lt-qcom/lava-job-definitions \
            --template-base-pre base_template.yaml \
            --template-names template-desktop.yaml template-gst-validate.yaml
      ;;
      rpb-wayland)
        echo "Currently no tests for rpb-wayland"
      ;;
    esac
    ;;
  *)
    echo "Skip DEVICE_TYPE for ${MACHINE}"
    ;;
esac

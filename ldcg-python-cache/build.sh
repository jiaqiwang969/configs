#!/bin/bash

set -xe

rm -rf ${WORKSPACE}/*

if [ -e /etc/debian_version ]; then
    echo "deb http://deb.debian.org/debian/ buster-backports main" | sudo tee /etc/apt/sources.list.d/backports.list
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y ansible/buster-backports
else
    sudo dnf -y distrosync
    sudo dnf -y install centos-release-ansible-29
    sudo dnf -y install ansible git
fi

git clone --depth 1 https://git.linaro.org/ci/job/configs.git

cd configs/ldcg-python-cache/ansible

echo "pip_extra_index_url: ${PIP_EXTRA_INDEX_URL}" >> vars/vars.yml
echo "python_packages: ${PYTHON_PACKAGES}" >> vars/vars.yml

ansible-playbook -i inventory playbooks/run.yml

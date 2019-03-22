#!/bin/bash

update_terraform()
{
    export TFVERS=0.11.13
    mkdir -p ̃~/.local/bin
    if [ ! -x ~/.local/bin/terraform_${TFVERS} ]
    then
        (
        cd /tmp
        wget https://releases.hashicorp.com/terraform/${TFVERS}/terraform_${TFVERS}_linux_amd64.zip
        unzip terraform_${TFVERS}_linux_amd64.zip
        cp terraform ~/.local/bin/terraform_${TFVERS}
        chmod a+x ~/.local/bin/terraform_${TFVERS}
        ln -sf terraform_${TFVERS}  ~/.local/bin/terraform
        )
    fi
}

set -e

echo ""
echo "########################################################################"
echo "    Gerrit Environment"
env |grep '^GERRIT'
echo "########################################################################"


cd terraform/
export GIT_PREVIOUS_COMMIT=$(git rev-parse HEAD~1)
export GIT_COMMIT=${GERRIT_PATCHSET_REVISION}
files=$(git diff --name-only ${GIT_PREVIOUS_COMMIT} ${GIT_COMMIT})
echo Changes in: ${files}
changed_dirs=$(dirname ${files})
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

update_terraform()

for dir in ${changed_dirs}; do
    cd $dir
    terraform init
    terraform plan --var-file *.tfvars -out demo.plan
    cd ..
done

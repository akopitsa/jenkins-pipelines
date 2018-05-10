#!/usr/local/bin/bash

set -o errexit
#set -o xtrace

#export AWS_DEFAULT_REGION=us-west-2
export AWS_DEFAULT_REGION=us-east-2

declare -A prod_code=(
    ["micro-amazon"]="Name=name,Values=amzn-ami-hvm-*-x86_64-gp2"
    ["min-centos-6-x64"]="Name=product-code,Values=6x5jmcajty9edm3f211pqjfn2"
    ["min-centos-7-x64"]="Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce"
    ["min-trusty-x64"]="Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"
    ["min-xenial-x64"]="Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"
    ["min-zesty-x64"]="Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-zesty-17.04-amd64-server-*"
    ["min-artful-x64"]="Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-artful-17.10-amd64-server-*"
    ["min-wheezy-x64"]="Name=name,Values=debian-wheezy-amd64-hvm-*"
    ["min-jessie-x64"]="Name=product-code,Values=3f8t6t8fp5m9xx18yzwriozxi"
    ["min-stretch-x64"]="Name=product-code,Values=55q52qvgjfpdj2fpfy9mb1lo4"
)

get_latest_ami() {
    local os=$1
    aws ec2 describe-images \
        --filters "${prod_code[$os]}" \
        --query 'Images[*].[CreationDate,ImageId,Name]' \
        --output text \
        | sort -n \
        | grep -v 2016.09 \
        | tail -1 \
        | awk '{print$2}'
}

main() {
    for os in $(echo "${!prod_code[@]}" | tr " " "\n" | sort -n); do
        if [ -n "${prod_code[$os]}" ]; then
            echo -n "imageMap['$os'] = '";
            get_latest_ami "$os"
        fi
    done
}

main
exit 0
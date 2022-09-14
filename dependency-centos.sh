#!/bin/bash

yum -y install docker && systemctl start docker && systemctl enable docker &&  yum install wget -y
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && yum install jq -y
systemctl restart docker
   echo    "----- ..................................................... -----"
   echo      "----- ...............   TERRAFORM .................... -----"
   echo    "----- ..................................................... -----"
wget https://releases.hashicorp.com/terraform/0.14.3/terraform_0.14.3_linux_amd64.zip
yum install unzip -y
unzip terraform_0.14.3_linux_amd64.zip
mv terraform /usr/bin/
sleep 5
   echo    "----- ..................................................... -----"
   echo        "----- ...............   HELM .................... -----"
   echo    "----- ..................................................... -----"
wget https://get.helm.sh/helm-v3.9.3-linux-amd64.tar.gz
tar -xzvf helm-v3.9.3-linux-amd64.tar.gz
mv linux-amd64/helm /usr/bin/helm
rm -rf helm-v3.9.3-linux-amd64.tar.gz && rm -rf linux-amd64
sleep 5
   echo    "----- ..................................................... -----"
   echo       "----- ...............   KUBECTL .................... -----"
   echo    "----- ..................................................... -----"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/bin/kubectl
                        

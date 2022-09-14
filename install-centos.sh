#!/usr/bin/env sh

set -e
cat <<EOF
Typical installation of the Local Environment , time of installation between 10-15 minutes
    1. ### Install Dependencys
    2. ### Create Kubernetes Cluster
    3. ### Deploy Charts of Application  
EOF
sleep 5
source dependency.sh
export DOMAIN_NAME="adi.com"
export path_folder="argocd"
sleep 5 && docker ps -a || true

             echo      "----- ............................. -----"
             echo           "---  LOAD-TERRAFORM-FILES  ---"
             echo      "----- ............................. -----"

sleep 5         
terraform init && terraform plan
terraform apply -auto-approve
sleep 10 && kubectl get pods -A && sleep 5

             echo        "----- ............................. -----"
             echo          "-----  HELM ADD REPOSITORY     -----"
             echo        "----- ............................. -----"
          
printf "\n Waiting for the echo web server service... \n"
sleep 10
kubectl get pods -A && sleep 5
helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo add hashicorp https://helm.releases.hashicorp.com|| true
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest || true
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts || true
helm repo add kedacore https://kedacore.github.io/charts || true
helm repo update

              echo        "----- ............................. -----"
              echo           "-----  INSTALL GLOBAL HELM     -----"
              echo        "----- ............................. -----"
  
source vault.sh || true
kubectl create namespace cattle-system || true
kubectl create namespace adi || true
kubectl -n cattle-system create secret tls adi --key adi.pem --cert adi.pem
kubectl -n adi create secret tls adi --key adi.pem --cert adi.pem
helm install rancher rancher-latest/rancher --version=v2.6.2 \
  --namespace cattle-system \
  --set hostname=console.adi.com \
  --set ingress.tls.source=adi \
  --set replicas=1 \
  --set bootstrapPassword=admin
sleep 5
kubectl create namespace keda || true
helm install keda kedacore/keda --namespace keda && sleep 5
echo    Waiting for all pods in running mode:
until kubectl wait --for=condition=Ready pods --all -n keda; do
sleep 2
done  2>/dev/null


              echo        "----- ............................. -----"
              echo            "-----  IMAGES PULL SECRET     -----"
              echo        "----- ............................. -----"   

sleep 5
bash regcred.sh
export MARIADB_ROOT_PASSWORD='123456abc'

              echo        "----- ............................. -----"
              echo           "---  LOAD-ARGO-APPLICATIONS  ---"
              echo        "----- ............................. -----"    

sleep 5 && 
kubectl apply -f ${path_folder}/secret.yaml
envsubst < ${path_folder}/pre-app.yaml > ${path_folder}/app.yaml
kubectl apply -f ${path_folder}/infra.yaml || true
kubectl apply -f ${path_folder}/app.yaml || true

              echo        "----- ............................. -----"
              echo            "---  LOAD-ARGO-EXPORTERS  ---"
              echo        "----- ............................. -----"  
sleep 5
kubectl apply -f ${path_folder}/exporters.yaml || true 
sleep 5
              echo        "----- ............................. -----"
              echo          "-----     CREATE INGRESS        -----"
              echo        "----- ............................. -----"   
              
kubectl delete ing rancher -n cattle-system || true
kubectl -n argocd create secret tls adi --key adi.pem --cert adi.pem
kubectl apply -f ${path_folder}/ingress-argocd.yaml || true
kubectl apply -f ${path_folder}/ingress-rancher.yaml || true
kubectl apply -f ${path_folder}/ingress-ui.yaml || true
sleep 5 && 
kubectl get nodes -o wide && sleep 5
terraform providers

              echo        "----- ............................. -----"
              echo            "-----       COMPLETE        -----"
              echo        "----- ............................. -----"

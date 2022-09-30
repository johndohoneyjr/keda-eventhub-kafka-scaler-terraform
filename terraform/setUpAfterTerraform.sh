#!/usr/bin/env bash

# Running in WSL environment, this alias is necessary
alias terraform="terraform.exe"

# Environment Variables
export SUBSCRIPTION_ID="e899c7bb-2371-4cff-b1c5-be57f7e1de31"
export clientID=$(cat gh-secret.json | jq -r .clientId)

alias terraform="terraform.exe"
RG=$(terraform.exe output resource_group_name)
export RESOURCE_GROUP=$(echo $RG | sed 's/"//g')
echo $RESOURCE_GROUP

CN=$(terraform.exe output aks_cluster_name)
export CLUSTER_NAME=$(echo $CN | sed 's/"//g')
echo $CLUSTER_NAME

ACR=$(terraform.exe output acr_name)
export REGISTRY=$(echo $ACR | sed 's/"//g')
echo $REGISTRY

echo "Adding Role assignments for ACR Pull ..."
az role assignment create --role "AcrPull" --assignee $clientID --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP

# Sanity check:  This command on windows updates the .kube/config in your windows directory, copy it to 
# your WSL $HOME/.kube -- it is a litle maddening :)
#
az aks get-credentials --name $CLUSTER_NAME --overwrite-existing --resource-group $RESOURCE_GROUP 

kubectl get ns
kubectl create namespace keda
kubectl get ns

helm repo add kedacore https://kedacore.github.io/charts
helm repo update

helm install keda kedacore/keda  --namespace keda
kubectl get all -n keda

echo "Sanity check , disabling admin registry access -- credentials NOT needed...simplier..."
az acr update --name $REGISTRY --resource-group $RESOURCE_GROUP --admin-enabled false | jq .adminUserEnabled
echoecho "Enjoy Keda.."
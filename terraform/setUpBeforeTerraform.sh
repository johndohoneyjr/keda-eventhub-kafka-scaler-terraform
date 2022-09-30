#!/usr/bin/env bash
# Running in WSL environment, this alias is necessary
alias terraform="terraform.exe"

# Environment Variables
export SUBSCRIPTION_ID="e899c7bb-2371-4cff-b1c5-be57f7e1de31"
export SERVICE_PRINCIPAL_NAME="johnd-serviceprincipal"

# Make sure jq is installed -- very handy command line tool
# https://stedolan.github.io/jq/download/
#

command -v jq >/dev/null 2>&1 || { echo >&2 "I require jq for this script, but it's not installed, download jq at: https://stedolan.github.io/jq/download/.  Aborting."; exit 1; }

if [[ -z "${SUBSCRIPTION_ID}" ]]; then
  clear
  echo "Please set SUBSCRIPTION_ID to the account you wish to use for set up of the AKS Cluster"
  exit 1
else
  echo "Using Subscription ID=$SUBSCRIPTION_ID for the following command set"
fi

if [[ -z "${SERVICE_PRINCIPAL_NAME}" ]]; then
  clear
  echo "Please set SERVICE_PRINCIPAL_NAME for the account you wish to use for set up of the AKS Cluster in"
  exit 1
else
  echo "Using Service Principal Name = $SERVICE_PRINCIPAL_NAME for the following commands"
fi


# Upgrade CLI
echo ""
echo "Checking to see if Azure CLI needs to be upgraded..."
echo ""
az upgrade

# Login to Owner account
echo ""
echo "Logging you into your account ..."
az login

echo "Creating Subscription Scoped Service Principal..."
az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --role Contributor --scopes /subscriptions/$SUBSCRIPTION_ID  --sdk-auth > gh-secret.json
export clientID=$(cat gh-secret.json | jq -r .clientId)
export clientSecret=$(cat gh-secret.json | jq -r .clientSecret)
cat variables.tf | sed "s/ClientID/$clientID/g" | sed "s/ClientSecret/$clientSecret/g" > foo.tf
cp foo.tf variables.tf
rm foo.tf

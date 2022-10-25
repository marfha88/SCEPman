# SCEPman

## This repo is built for  deploying SCEPman using bicep with github actions

* The deployment uses the deploytime function to generate new deployment name each time.
*  deploytime=$(date +"%m-%d-%y-%H")
   --name rollout-$deploytime

## Deploying from github

* Read https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure and 
https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Clinux#use-the-azure-login-action-with-openid-connect

* We will use openID connect to safely deploy resources to azure using github actions which will have automatic key rotation during each workflow run

# Deploying locally (Just for testing and what-if)

You can use the below command to deploy locally.

```
az login
az account list
az account set -s "subscriptionid"
az deployment group what-if -g yourrg --name rollout01 -f .\main.bicep

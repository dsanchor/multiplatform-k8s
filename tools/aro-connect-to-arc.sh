

#!/bin/bash

AROCLUSTER=$1
ARORG=$2
LOCATION=$3

# Install the connectedk8s Azure CLI extension
az extension add --name connectedk8s
az extension add --name k8s-extension

# Register providers for Azure Arc-enabled Kubernetes
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.KubernetesConfiguration
az provider register --namespace Microsoft.ExtendedLocation

# Monitor the registration process. Registration may take up to 10 minutes.
# Once registered, you should see the RegistrationState state for these namespaces change to Registered.
az provider show -n Microsoft.Kubernetes -o table
az provider show -n Microsoft.KubernetesConfiguration -o table
az provider show -n Microsoft.ExtendedLocation -o table

# Add a policy to enable arc
# You are granting service account azure-arc-kube-aad-proxy-sa in Project azure-arc to the privileged SCC permission
oc adm policy add-scc-to-user privileged system:serviceaccount:azure-arc:azure-arc-kube-aad-proxy-sa

# Connect the cluster to Arc
az connectedk8s connect --name $AROCLUSTER --resource-group $ARORG --location $LOCATION

# Verify cluster connection
az connectedk8s list --resource-group $ARORG --output table

# Check the deployment and pods. All deployment should be ready and all Pods should be in Ready and in Running state
oc get deployments,pods -n azure-arc
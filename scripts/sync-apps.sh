#!/bin/bash

set -e

ENVIRONMENT=${1:-all}

sync_app() {
    local app_name=$1
    echo "Syncing application: $app_name"
    argocd app sync $app_name
    argocd app wait $app_name --timeout 300
    echo "Application $app_name synced successfully"
}

if [[ "$ENVIRONMENT" == "all" ]]; then
    echo "Syncing all applications..."
    sync_app k8s-cicd-dev
    sync_app k8s-cicd-staging
    sync_app k8s-cicd-prod
elif [[ "$ENVIRONMENT" == "development" ]]; then
    sync_app k8s-cicd-dev
elif [[ "$ENVIRONMENT" == "staging" ]]; then
    sync_app k8s-cicd-staging
elif [[ "$ENVIRONMENT" == "production" ]]; then
    sync_app k8s-cicd-prod
else
    echo "Error: Environment must be one of: development, staging, production, all"
    exit 1
fi

echo "Sync completed for $ENVIRONMENT!"

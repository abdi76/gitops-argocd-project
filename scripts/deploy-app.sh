#!/bin/bash

set -e

ENVIRONMENT=${1:-development}
IMAGE_TAG=${2:-latest}
SYNC=${3:-false}

if [[ "$ENVIRONMENT" != "development" && "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
    echo "Error: Environment must be one of: development, staging, production"
    exit 1
fi

echo "Deploying k8s-cicd-app to $ENVIRONMENT environment with image tag: $IMAGE_TAG"

# Update image tag in kustomization
KUSTOMIZATION_FILE="applications/k8s-cicd-app/overlays/$ENVIRONMENT/kustomization.yaml"

if [[ "$ENVIRONMENT" == "production" ]]; then
    if [[ "$IMAGE_TAG" == "latest" ]]; then
        echo "Warning: Using 'latest' tag in production is not recommended"
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

# Update the image tag
if command -v yq &> /dev/null; then
    yq eval '.images[0].newTag = "'$IMAGE_TAG'"' -i $KUSTOMIZATION_FILE
else
    sed -i "s/newTag: .*/newTag: $IMAGE_TAG/" $KUSTOMIZATION_FILE
fi

# Commit and push changes
git add $KUSTOMIZATION_FILE
git commit -m "deploy: update $ENVIRONMENT to image tag $IMAGE_TAG"
git push origin main

echo "Updated $ENVIRONMENT deployment configuration"

# Trigger ArgoCD sync if requested
if [[ "$SYNC" == "true" ]]; then
    echo "Triggering ArgoCD sync..."
    argocd app sync k8s-cicd-$ENVIRONMENT
    argocd app wait k8s-cicd-$ENVIRONMENT --timeout 300
    echo "Deployment completed!"
fi

echo "GitOps deployment initiated for $ENVIRONMENT environment"
echo "Check ArgoCD UI for deployment status: https://localhost:8080"

#!/bin/bash

set -e

NAMESPACE="argocd"
ARGOCD_VERSION="v2.8.4"

echo "Setting up ArgoCD..."

# Create namespace
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
echo "Installing ArgoCD $ARGOCD_VERSION..."
kubectl apply -n $NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/$ARGOCD_VERSION/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n $NAMESPACE

# Apply custom configuration
echo "Applying custom ArgoCD configuration..."
kubectl apply -f argocd/install/

# Get ArgoCD admin password
echo "Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD Admin Password: $ARGOCD_PASSWORD"

# Port forward ArgoCD UI (run in background)
echo "Setting up port forwarding for ArgoCD UI..."
kubectl port-forward svc/argocd-server -n $NAMESPACE 8080:443 &
PORT_FORWARD_PID=$!

echo "ArgoCD setup completed!"
echo "Access ArgoCD UI at: https://localhost:8080"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"

# Install ArgoCD CLI
if ! command -v argocd &> /dev/null; then
    echo "Installing ArgoCD CLI..."
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_VERSION/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64
fi

# Login to ArgoCD CLI
echo "Logging in to ArgoCD CLI..."
argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure

# Apply ArgoCD applications
echo "Applying ArgoCD project and applications..."
kubectl apply -f argocd/projects/
sleep 5
kubectl apply -f argocd/applications/

echo "Setup completed! ArgoCD is running at https://localhost:8080"
echo "To stop port forwarding, run: kill $PORT_FORWARD_PID"

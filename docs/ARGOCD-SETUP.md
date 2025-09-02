# ArgoCD Setup Guide

## Installation

### Prerequisites
- Kubernetes cluster with kubectl access
- Sufficient cluster resources (2 CPU, 4Gi memory)
- Ingress controller (optional, for external access)

### Quick Setup
```bash
# Run setup script
./scripts/setup-argocd.sh
```

### Manual Installation
```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for deployment
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Configuration

### External Access
```bash
# NodePort (for local clusters)
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort"}}'

# LoadBalancer (for cloud clusters)
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"LoadBalancer"}}'

# Ingress (recommended for production)
kubectl apply -f argocd/install/install.yaml
```

### CLI Installation
```bash
# Linux
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

# macOS
brew install argocd

# Login
argocd login localhost:8080
```

## Application Management

### Create Application
```bash
argocd app create k8s-cicd-dev \
  --project k8s-cicd-project \
  --repo https://github.com/your-username/gitops-argocd-project \
  --path applications/k8s-cicd-app/overlays/development \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace k8s-cicd-dev \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

### Sync Application
```bash
# Manual sync
argocd app sync k8s-cicd-dev

# Wait for sync completion
argocd app wait k8s-cicd-dev

# View sync status
argocd app get k8s-cicd-dev
```

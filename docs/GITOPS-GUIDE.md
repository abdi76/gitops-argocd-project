# GitOps Guide

## Overview

This guide explains the GitOps workflow implemented with ArgoCD for the K8s CI/CD application.

## GitOps Principles

1. **Declarative**: All configuration is stored in Git as YAML manifests
2. **Versioned**: Git provides version control for all changes
3. **Automated**: ArgoCD automatically syncs cluster state with Git
4. **Observable**: All changes are tracked and auditable

## Repository Structure

### Applications Directory
- `applications/k8s-cicd-app/base/`: Base Kubernetes manifests
- `applications/k8s-cicd-app/overlays/`: Environment-specific customizations

### ArgoCD Directory
- `argocd/applications/`: ArgoCD Application definitions
- `argocd/projects/`: ArgoCD Project definitions
- `argocd/install/`: ArgoCD installation and configuration

## Environments

### Development
- **Namespace**: k8s-cicd-dev
- **Sync Policy**: Automated with self-healing
- **Replicas**: 1
- **Resources**: Minimal (32Mi memory, 25m CPU)

### Staging
- **Namespace**: k8s-cicd-staging
- **Sync Policy**: Manual approval required
- **Replicas**: 2
- **Resources**: Standard (64Mi memory, 50m CPU)

### Production
- **Namespace**: k8s-cicd-prod
- **Sync Policy**: Manual approval required
- **Replicas**: 3 (with HPA)
- **Resources**: Full (256Mi memory, 200m CPU)

## Deployment Workflow

1. **Code Changes**: Developers push code to application repository
2. **CI Pipeline**: Build and test application, push image to registry
3. **Manifest Update**: Update image tags in GitOps repository
4. **ArgoCD Sync**: ArgoCD detects changes and syncs to cluster
5. **Validation**: Health checks ensure successful deployment

## Best Practices

### Image Tagging
- Development: Use `dev-latest` or commit SHA
- Staging: Use `staging-latest` or release candidates
- Production: Use semantic version tags (v1.0.0)

### Configuration Management
- Use Kustomize for environment-specific configuration
- Keep sensitive data in Kubernetes Secrets
- Use ConfigMaps for non-sensitive configuration

### Security
- Enable RBAC for namespace isolation
- Use network policies for traffic control
- Scan images for vulnerabilities before deployment

## Troubleshooting

### Application Out of Sync
```bash
# Check application status
argocd app get k8s-cicd-dev

# View differences
argocd app diff k8s-cicd-dev

# Manual sync
argocd app sync k8s-cicd-dev
```

### Failed Deployment
```bash
# Check pod status
kubectl get pods -n k8s-cicd-dev

# View pod logs
kubectl logs -l app=k8s-cicd-app -n k8s-cicd-dev

# Check events
kubectl get events -n k8s-cicd-dev --sort-by='.lastTimestamp'
```

## Rollback Procedures

### Using ArgoCD
```bash
# View revision history
argocd app history k8s-cicd-prod

# Rollback to previous version
argocd app rollback k8s-cicd-prod <revision-id>
```

### Using Git
```bash
# Revert Git commit
git revert <commit-hash>
git push origin main
```

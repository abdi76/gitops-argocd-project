# GitOps with ArgoCD

[![GitOps Validation](https://github.com/your-username/gitops-argocd-project/actions/workflows/gitops-validation.yml/badge.svg)](https://github.com/your-username/gitops-argocd-project/actions/workflows/gitops-validation.yml)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A production-ready GitOps implementation using ArgoCD for managing Kubernetes deployments across multiple environments.

## Features

- **Multi-Environment Management**: Development, Staging, and Production environments
- **Kustomize Integration**: Environment-specific configurations with overlays
- **Automated Deployments**: GitOps workflow with ArgoCD
- **Security Best Practices**: RBAC, security contexts, and policy validation
- **Monitoring Ready**: Prometheus metrics and ServiceMonitor integration
- **Production Ready**: HPA, ingress, and comprehensive health checks

## Quick Start

1. **Setup ArgoCD**:
   ```bash
   ./scripts/setup-argocd.sh
   ```

2. **Deploy to Development**:
   ```bash
   ./scripts/deploy-app.sh development dev-latest
   ```

3. **Access ArgoCD UI**:
   - URL: https://localhost:8080
   - Username: admin
   - Password: (displayed by setup script)

## Repository Structure

```
├── applications/           # Kustomize application configs
├── argocd/                # ArgoCD configurations
├── infrastructure/        # Infrastructure components
├── scripts/              # Automation scripts
└── docs/                 # Documentation
```

## Environments

| Environment | Namespace | Sync Policy | Replicas | Resources |
|-------------|-----------|-------------|----------|-----------|
| Development | k8s-cicd-dev | Automated | 1 | Minimal |
| Staging | k8s-cicd-staging | Manual | 2 | Standard |
| Production | k8s-cicd-prod | Manual | 3+ (HPA) | Full |

## Deployment Workflow

1. Update application image tags in overlays
2. Commit and push to main branch  
3. ArgoCD detects changes and syncs to cluster
4. Monitor deployment in ArgoCD UI

## Scripts

- `scripts/setup-argocd.sh`: Install and configure ArgoCD
- `scripts/deploy-app.sh`: Deploy application to specific environment
- `scripts/sync-apps.sh`: Manually sync ArgoCD applications

## Documentation

- [GitOps Guide](docs/GITOPS-GUIDE.md)
- [ArgoCD Setup](docs/ARGOCD-SETUP.md)

## License

This project is licensed under the MIT License.

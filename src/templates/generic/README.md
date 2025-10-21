# Gitea Templates

This directory contains templates and configuration files for tfgrid-gitea deployments.

## Structure

- `generic/` - Generic templates that work across all deployment patterns
- Future: `gateway/` - Gateway-specific templates
- Future: `k3s/` - Kubernetes-specific templates

## Usage

Templates are automatically copied to the VM during deployment and can be referenced by scripts in the `src/scripts/` directory.
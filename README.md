# Homelab

This repository documents a learning-oriented but production-inspired GitOps monorepo for a Kubernetes-based homelab platform.

The goal is not just to run a few services locally, but to build a coherent platform story:
a GitOps-managed, observable, and extensible Kubernetes platform that can later be extended towards edge gateways and real-world sensor integration.

## Goals

The platform is built step by step with a focus on:

- GitOps-based cluster and application delivery with Argo CD
- ingress-based service exposure inside a local homelab network
- observable platform operations with Prometheus, Grafana, Loki, and Tempo
- stateful workloads with persistence, backup, and restore concepts
- later extension towards edge telemetry and sensor ingestion

## Current Focus

The current platform work focuses on the Kubernetes base platform:

- Argo CD for GitOps-style deployment
- ingress-nginx for HTTP ingress routing
- kube-prometheus-stack for observability
- example services and workloads for end-to-end deployment validation

Planned next steps include:

- Prometheus Blackbox Exporter for reachability and latency checks
- Pi-hole as a cluster-integrated DNS service for the homelab network
- Paperless-ngx as a first real stateful workload
- later edge integration via Raspberry Pi and ESP32-based sensors

## Repository Structure

```text
clusters/
  dev/                  # local dev cluster configuration
  prod/                 # future production/home cluster entrypoints

bootstrap/              # local bootstrap scripts

gitops/
  applicationsets/      # Argo CD ApplicationSets
  manifests/
    namespaces/         # shared namespaces
    platform/           # platform components
    services/           # reusable services
    workloads/          # application workloads
```

## Architecture Approach

The repository is intentionally structured like a small platform monorepo:
- `clusters/` contains cluster-specific entrypoints
- `gitops/applicationsets/` contains Argo CD application definitions
- `gitops/manifests/` contains the actual Kubernetes manifests
- platform concerns are separated from services and workloads

This keeps cluster bootstrapping, platform rollout, and workload deployment conceptually separated

### Development Cluster
The local development environment currently uses kind.

#### Prerequisites
- Docker
- kind
- kubectl

#### Bootstrap
```bash
cd bootstrap
./bootstrap-dev.sh
```

This bootstraps:
- a local kind cluster
- Argo CD
- ingress-nginx
- kube-prometheus-stack
- example services and workloads

### Local Access

The development setup uses hostnames under `dev.home.arpa`
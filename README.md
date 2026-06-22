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


- kind dev cluster
- Argo CD for GitOps-style deployment
- ingress-nginx via Helm
- local-path provisioner with standard StorageClass
- kube-prometheus-stack for observability
- Prometheus blackbox exporter
- Loki single-binary with persistence
- Sealed Secrets
- example services and workloads for end-to-end deployment validation
- paperless-ngx + redis + postgres

Planned next steps include:

- Cluster wide log collection via alloy
- Tempo and some traces
- Pi-hole as a cluster-integrated DNS service for the homelab network
- Paperless-ngx automatic backups (first to disk then to cloud) 
- later edge integration via Raspberry Pi and ESP32-based sensors
- ?

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
      argocd/
      storage/
      observability/
        metrics/
        logs/
        traces/
        collectors/
    workloads/          # application and demo workloads
```

## Architecture Approach

The repository is intentionally structured like a small platform monorepo:
- `clusters/` contains cluster-specific entrypoints
- `bootstrap/` contains the local bootstrap workflow for the dev cluster
- `gitops/applicationsets/` contains Argo CD application definitions
- `gitops/manifests/` contains the actual Kubernetes manifests
- platform concerns are separated from workloads
- observability is organized by signal type and component domain

This keeps cluster bootstrapping, platform rollout, and workload deployment conceptually separated

### Development Cluster
The local development environment currently uses kind.

#### Prerequisites
- Docker
- kind
- kubectl

#### Bootstrap

The bootstrap script renders a temporary kind config from `clusters/dev/kind-config.example.yaml`.
By default it stores local-path provisioner data under `.local/dev-storage` in this repository.
You can override that location with `DEV_STORAGE_PATH=/absolute/path/to/storage`.

```bash
cd bootstrap
./bootstrap-dev.sh
```

Example with a custom storage path:

```bash
cd bootstrap
DEV_STORAGE_PATH=/srv/homelab-dev-storage ./bootstrap-dev.sh
```

This bootstraps:
- a local kind cluster
- Argo CD
- ingress-nginx
- local-path storage
- kube-prometheus-stack
- Prometheus Blackbox Exporter
- Loki
- example workloads and stateful applications

### Local Access

The development setup uses hostnames under `dev.home.arpa`. For example:
- argocd.dev.home.arpa
- grafana.dev.home.arpa
- loki.dev.home.arpa
- calculator.dev.home.arpa
- demo.dev.home.arpa
- dms.dev.home.arpa

For local name resolution, add them to `/etc/hosts` and point them to `127.0.0.1` because the kind control-plane maps ports `80` and `443` to your host:

```text
127.0.0.1 argocd.dev.home.arpa grafana.dev.home.arpa loki.dev.home.arpa calculator.dev.home.arpa demo.dev.home.arpa dms.dev.home.arpa
```

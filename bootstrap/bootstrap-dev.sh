#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CLUSTER_NAME="homelab-dev"
KIND_CONFIG_TEMPLATE="${REPO_ROOT}/clusters/dev/kind-config.example.yaml"
DEV_STORAGE_PATH="${DEV_STORAGE_PATH:-${REPO_ROOT}/.local/dev-storage}"
KIND_CONFIG="$(mktemp)"

cleanup() {
  rm -f "${KIND_CONFIG}"
}

trap cleanup EXIT

mkdir -p "${DEV_STORAGE_PATH}"

echo "Rendering kind config from template..."
sed "s|/path/to/your/dev-storage|${DEV_STORAGE_PATH}|g" \
  "${KIND_CONFIG_TEMPLATE}" > "${KIND_CONFIG}"

echo "Deleting old cluster (if exists)..."
kind delete cluster --name "${CLUSTER_NAME}" || true

echo "Creating cluster..."
kind create cluster --name "${CLUSTER_NAME}" --config "${KIND_CONFIG}"

echo "Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "Installing minimal ArgoCD core..."
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD server deployment..."
kubectl rollout status deployment argocd-server -n argocd --timeout=180s

echo "Ensuring ArgoCD runs in insecure mode..."
if ! kubectl -n argocd get deployment argocd-server -o json | grep -q -- '--insecure'; then
  kubectl -n argocd patch deployment argocd-server \
    --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--insecure"}]'

  echo "Waiting for ArgoCD restart..."
  kubectl rollout status deployment argocd-server -n argocd --timeout=180s
else
  echo "ArgoCD already configured with --insecure"
fi

echo "Applying root application..."
kubectl apply -n argocd -f "${REPO_ROOT}/clusters/dev/root-app.yaml"

echo "Bootstrap complete."

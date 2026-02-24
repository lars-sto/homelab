#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="homelab-dev"
KIND_CONFIG="clusters/dev/kind-config.yaml"

echo "Deleting old cluster (if exists)..."
kind delete cluster --name "${CLUSTER_NAME}" || true

echo "Creating cluster..."
kind create cluster --name "${CLUSTER_NAME}" --config "${KIND_CONFIG}"

echo "Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "Installing minimal ArgoCD core..."
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml

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
kubectl apply -n argocd -f clusters/dev/root-app.yaml

echo "Bootstrap complete."
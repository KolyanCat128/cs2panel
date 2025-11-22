#!/bin/bash
set -e

# CS2Panel Deployment Script
# Deploys the complete infrastructure to Kubernetes

NAMESPACE="cs2panel"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."

echo "Deploying CS2Panel Infrastructure"
echo "=================================="

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed"
    exit 1
fi

# Check Helm
if ! command -v helm &> /dev/null; then
    echo "Error: Helm is not installed"
    exit 1
fi

# Create namespace
echo "Creating namespace..."
kubectl apply -f "${ROOT_DIR}/k8s/namespace.yaml"

# Create secrets
echo "Creating secrets..."
read -sp "Enter JWT secret: " JWT_SECRET
echo
read -sp "Enter database password: " DB_PASSWORD
echo
read -sp "Enter DeepSeek API key (optional): " DEEPSEEK_KEY
echo

kubectl create secret generic cs2panel-secrets \
    --from-literal=jwt-secret="${JWT_SECRET}" \
    --from-literal=db-username=cs2panel \
    --from-literal=db-password="${DB_PASSWORD}" \
    --from-literal=deepseek-api-key="${DEEPSEEK_KEY}" \
    --namespace="${NAMESPACE}" \
    --dry-run=client -o yaml | kubectl apply -f -

# Apply CRDs
echo "Applying Custom Resource Definitions..."
kubectl apply -f "${ROOT_DIR}/k8s/crd-cs2server.yaml"

# Deploy using Helm
echo "Deploying via Helm..."
helm upgrade --install cs2panel "${ROOT_DIR}/charts/cs2panel" \
    --namespace="${NAMESPACE}" \
    --create-namespace \
    --set secrets.jwtSecret="${JWT_SECRET}" \
    --set secrets.deepseekApiKey="${DEEPSEEK_KEY}" \
    --set postgresql.auth.password="${DB_PASSWORD}" \
    --wait

# Wait for pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod \
    -l app.kubernetes.io/name=cs2panel \
    --namespace="${NAMESPACE}" \
    --timeout=300s

echo "=================================="
echo "Deployment completed successfully!"
echo ""
echo "Access the API:"
echo "  kubectl port-forward -n ${NAMESPACE} svc/cs2panel-backend 8080:8080"
echo ""
echo "View logs:"
echo "  kubectl logs -n ${NAMESPACE} -l component=backend -f"
echo ""
echo "Create a CS2 server:"
echo "  kubectl apply -f ${ROOT_DIR}/k8s/example-cs2server.yaml"

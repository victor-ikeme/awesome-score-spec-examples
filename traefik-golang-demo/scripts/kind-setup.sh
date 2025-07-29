#!/bin/bash
set -o errexit
set -o pipefail

# Create a local Kind cluster with port 80 exposed
echo "🔧 Creating local Kind cluster..."
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 31000
    hostPort: 80
    protocol: TCP
EOF

# Install Gateway API CRDs
echo "📡 Installing Gateway API CRDs..."
GATEWAY_API_VERSION=$(curl -sL https://api.github.com/repos/kubernetes-sigs/gateway-api/releases/latest | jq -r .tag_name)

kubectl apply \
  -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml

# Optional GitHub token prompt
echo "🔐 Authenticating to GitHub Container Registry (ghcr.io)..."
if [ -z "$GHCR_PAT" ]; then
  read -s -p "Enter your GitHub Personal Access Token (CR_PAT) for ghcr.io: " GHCR_PAT
  echo
fi

# Login to ghcr.io using Helm (OCI)
echo "$GHCR_PAT" | helm registry login ghcr.io -u victor-ikeme --password-stdin || {
  echo "⚠️ Failed to authenticate with ghcr.io. Skipping NGF installation."
  exit 1
}

# Install NGINX Gateway Fabric
echo "🚀 Installing NGINX Gateway Fabric via Helm..."
helm install ngf oci://ghcr.io/nginxinc/charts/nginx-gateway-fabric \
  --create-namespace \
  -n nginx-gateway \
  --set service.type=NodePort \
  --set-json 'service.ports=[{"port":80,"nodePort":31000}]'

# Apply default Gateway config
echo "📦 Applying default Gateway manifest..."
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: default
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
EOF

echo "✅ Kind cluster with Gateway API + NGF is ready!"

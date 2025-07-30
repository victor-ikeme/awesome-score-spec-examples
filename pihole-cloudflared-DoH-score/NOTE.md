# Pi-hole and Cloudflared on Kubernetes with Score

This project demonstrates how to deploy a complex networking application (Pi-hole and Cloudflared) to Kubernetes using a portable Score definition.

## Kubernetes Architecture

The `score-k8s` tool translates our abstract `score.yaml` files into native Kubernetes resources.

*   **Workloads ➡️ `Deployment` + `Service`**: Each Score file (`cloudflared-dns`, `pihole-server`) becomes a Kubernetes `Deployment` to manage its Pods and a `Service` to provide a stable internal DNS name and network endpoint.
*   **Static IP ➡️ Kubernetes Service DNS**: Instead of a static IP, the Pi-hole container is configured to use the Kubernetes DNS name for the Cloudflared service (`cloudflared-dns`). This is a more robust and idiomatic pattern for service discovery in Kubernetes.
*   **`cap_add` ➡️ `securityContext`**: The privileged `NET_ADMIN` requirement is not part of the `score.yaml`. A **patch template** (`k8s-net-admin.patch.tpl`) is provided by the platform engineer to inject the necessary `securityContext.capabilities.add` block into the Pi-hole Pod specification.

## How to Run with `score-k8s`

**Important Note:** Exposing DNS and DHCP services from a Kubernetes cluster to your broader physical network is an advanced networking topic that may require `LoadBalancer` services, `ExternalIPs`, or specific CNI configurations, which are beyond the scope of this basic deployment guide. This guide will get the services running inside the cluster.

### Step 1: Create a `.env` file
Provide the necessary configuration for your environment.
```bash
cp .env.example .env
# Edit .env and set your values
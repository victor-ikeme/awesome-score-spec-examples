# Prometheus and Grafana Monitoring Stack (for Kubernetes)

This project demonstrates how to define a classic monitoring stack for Kubernetes using Score. The architecture consists of two distinct workloads: a Prometheus server and a Grafana instance.

## Architecture

This project is defined as two separate `score.yaml` files. When processed by `score-k8s`, these will generate all the necessary Kubernetes resources (`Deployment`, `Service`, `ConfigMap`, `Secret`, `PersistentVolumeClaim`).

*   **`prometheus-service` Workload**: This stateful service is responsible for data collection. Its Score file defines:
    *   A Kubernetes `Service` via the `service.ports` block.
    *   A `PersistentVolumeClaim` via the `resources.prom-data` block of `type: volume`.
    *   A `ConfigMap` via the `containers.files` block, which mounts the `prometheus.yml`.
*   **`grafana-service` Workload**: The visualization layer. Its Score file defines:
    *   A `service` dependency on `prometheus-service`, which allows it to discover Prometheus via the cluster's internal DNS.
    *   A `ConfigMap` for its `datasource.yml` configuration.
    *   A dependency on an `environment` resource for its admin credentials. `score-k8s` will translate this into a Kubernetes `Secret`.

## Key Score Concepts Translated to Kubernetes

*   **`score.yaml` ➡️ `Deployment`, `Service`**: Each Score file is translated into a `Deployment` and a `Service`.
*   `containers.files` ➡️ `ConfigMap`: The `files` directive is the canonical way to manage configuration files, which `score-k8s` implements using `ConfigMaps`.
*   `resources` of `type: volume` ➡️ `PersistentVolumeClaim`: A request for persistent storage is translated directly into a PVC.
*   `resources` of `type: environment` ➡️ `Secret`: The request for environment variables (especially secrets) is fulfilled by `score-k8s` by creating a Kubernetes `Secret` and injecting the values into the Pod.

## How to Run with `score-k8s`

1.  **Create a `.env` file:**
    `score-k8s` will use this file to create the Kubernetes `Secret` for Grafana.
    ```bash
    cp .env.example .env
    # Edit .env and set your desired admin credentials
    ```

2.  **Generate the Kubernetes Manifests:**
    Use `score-k8s` to generate a single `manifests.yaml` file from both Score specifications.
    ```bash
    score-k8s generate *.yaml --env-file .env -o manifests.yaml
    ```
    *Note: The `--env-file .env` flag explicitly tells `score-k8s` where to find the values for the `environment` resource.*

3.  **Deploy the Application:**
    ```bash
    kubectl apply -f manifests.yaml
    ```

4.  **Access Grafana:**
    You will need to expose the Grafana service to access it. The simplest way for local testing is `port-forward`.
    ```bash
    kubectl port-forward svc/grafana-service 3000:3000
    ```
    You can now access the Grafana UI at **`http://localhost:3000`**.
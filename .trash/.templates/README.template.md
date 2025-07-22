# {{ workload_name | title }} — Score.dev Workload Example

This project demonstrates how to deploy the `{{ workload_name }}` workload using [Score.dev](https://score.dev), via:

- `score-compose` (Docker Compose for local dev)
- `score-k8s` (Kubernetes deployment via Kind cluster)

Run the steps manually or use the Makefile-based shortcuts provided.

---

## 📁 Project Structure

```
{{ workload_name }}/
├── {{ app_dir }}/                  # App source (Dockerfile lives here)
├── score/
│   └── score.yaml                 # Workload spec (Score.dev)
├── manifests.yaml                 # Kubernetes manifest (generated)
├── compose.yaml                   # Docker Compose file (generated)
├── Makefile                       # Automates dev & test workflows
└── scripts/
    └── setup-kind-cluster.sh     # Optional kind cluster setup
```

---

## ⚙️ Prerequisites

Ensure the following tools are installed:

- [`score-compose`](https://github.com/score-spec/score-compose)
- [`score-k8s`](https://github.com/score-spec/score-k8s)
- [`Docker`](https://www.docker.com/)
- [`kind`](https://kind.sigs.k8s.io/)
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/)
- `curl` (for testing endpoints)

---

## 🛠️ Deploying with Score (Manually)

### ✅ 1. Build the container image

```bash
docker build -t {{ image_tag }} ./{{ app_dir }}
```

---

### 🐳 2. Deploy Locally with Docker Compose (`score-compose`)

#### a. Initialize score-compose

```bash
score-compose init --no-sample {% if dns_enabled %}\
  --provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/dns/score-compose/10-dns-with-url.provisioners.yaml{% endif %}
```

#### b. Generate Docker Compose file

```bash
score-compose generate score/score.yaml \
  --build '{{ container_name }}={"context":"{{ app_dir }}","tags":["{{ image_tag }}"]}' {% if dns_enabled %}\
  --publish {{ port }}:{{ workload_name }}:{{ port }}{% endif %}
```

#### c. Launch app locally

```bash
docker compose up --build -d
```

#### d. Test

{% if dns_enabled %}
```bash
score-compose resources get-outputs dns.default#{{ workload_name }}.dns --format '{{ '{{ .host }}' }}'
```
{% else %}
```bash
curl http://localhost:{{ port }}
```
{% endif %}

---

### ☸️ 3. Deploy to Kubernetes (`score-k8s`)

#### a. Initialize score-k8s

```bash
score-k8s init --no-sample {% if dns_enabled %}\
  --provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/dns/score-k8s/10-dns-with-url.provisioners.yaml{% endif %}
```

#### b. Generate manifests

```bash
score-k8s generate score/score.yaml \
  --image {{ image_tag }}
```

#### c. Setup Kind cluster (if needed)

```bash
./scripts/setup-kind-cluster.sh
```

#### d. Load image into Kind

```bash
kind load docker-image {{ image_tag }}
```

#### e. Deploy to Kubernetes

```bash
kubectl apply -f manifests.yaml
```

#### f. Test

{% if dns_enabled %}
```bash
score-k8s resources get-outputs dns.default#{{ workload_name }}.dns --format '{{ '{{ .host }}' }}'
```
{% else %}
```bash
kubectl port-forward svc/{{ workload_name }} {{ port }}:{{ port }}
```
Open `http://localhost:{{ port }}` in your browser.
{% endif %}

---

## ⚡ Quick Start Using `make`

This project includes a [Makefile](./Makefile) that automates the above steps.

### 🔨 Local Dev with Docker Compose

```bash
make compose-up COMPOSE_PUBLISH={{ dns_enabled }} DNS_ENABLED={{ dns_enabled }}
```

### 🔍 View logs

```bash
make compose-logs
```

### 🧼 Tear down

```bash
make compose-down
```

---

### ☸️ Deploy to Kubernetes (Kind)

```bash
make kind-create-cluster
make kind-load-image
make k8s-up DNS_ENABLED={{ dns_enabled }} USE_PATCHES=true
```

### 🔁 Test DNS or port-forward

```bash
make k8s-test DNS_ENABLED={{ dns_enabled }}
```

### 📜 View k8s logs

```bash
make k8s-logs
```

### 🧼 Clean up k8s

```bash
make k8s-down
```

---

## 🤖 Tip: Multi-Service Support

This template is used across multiple workloads and microservices under the [`awesome-score-spec-examples`](https://github.com/YOUR-ORG/awesome-score-spec-examples) project. For multi-service projects, just run `make` with different `WORKLOAD_NAME=` or loop over a list of services.

---

## 📚 Resources

* [Score.dev Docs](https://score.dev/docs)
* [score-compose GitHub](https://github.com/score-spec/score-compose)
* [score-k8s GitHub](https://github.com/score-spec/score-k8s)

---

Built with ❤️ for Platform Engineers.

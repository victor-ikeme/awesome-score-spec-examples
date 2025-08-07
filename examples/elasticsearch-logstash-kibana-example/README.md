# 🧩 ELK Stack (Elasticsearch, Logstash, Kibana) Deployed with Score

Welcome to the **Awesome Score Spec Examples** repository!

This project showcases real-world, platform-ready workloads using the [**Score**](https://score.dev) workload specification — deployable across:

- 🐳 **Docker Compose** (via `score-compose`)
- ☸️ **Kubernetes** (via `score-k8s`)
- 🛠 **Humanitec’s Internal Developer Platform (IDP)**

Whether you're a developer seeking faster feedback loops or a platform engineer designing reusable infrastructure, these examples demonstrate how Score cleanly separates **application intent** from **infrastructure implementation**.

> ✅ This README focuses on the **ELK Stack** example — a powerful observability platform featuring Elasticsearch, Logstash, and Kibana.

![ELK Stack with Score](https://res.cloudinary.com/cloudikeme/image/upload/v1754145383/cc98ebligzricim5ibey.png)

---

## 💡 Why Score?

**Score** is a developer-first, runtime-agnostic spec that defines *what* your application needs — not *how* it's deployed. It enables:

- **Clean developer handoffs** using a unified `score.yaml`
- **Environment portability** (local, staging, prod)
- **Composable infrastructure** via provisioners
- **CI/CD automation** without handwritten YAML

With Score, your ELK stack becomes **repeatable, portable, and platform-aligned**.

---

## 📚 Table of Contents

- [🧩 ELK Stack (Elasticsearch, Logstash, Kibana) Deployed with Score](#-elk-stack-elasticsearch-logstash-kibana-deployed-with-score)
  - [💡 Why Score?](#-why-score)
  - [📚 Table of Contents](#-table-of-contents)
  - [🚀 Getting Started](#-getting-started)
  - [🛠 Prerequisites](#-prerequisites)
  - [🔎 ELK Stack Overview](#-elk-stack-overview)
  - [⚡️ Quick Start](#️-quick-start)
    - [🐳 Docker Compose](#-docker-compose)
    - [☸️ Kubernetes (Kind)](#️-kubernetes-kind)
    - [🛠 Humanitec (Cloud-Native IDP)](#-humanitec-cloud-native-idp)
  - [🤖 CI/CD with GitHub Actions](#-cicd-with-github-actions)
    - [🧪 Sample: `.github/workflows/ci.yml`](#-sample-githubworkflowsciyml)
  - [📖 Tutorial Series](#-tutorial-series)
  - [🤝 Contributing](#-contributing)
    - [👣 How to Contribute](#-how-to-contribute)
    - [✨ Ideas for Contribution](#-ideas-for-contribution)
  - [⚖️ License](#️-license)

---

## 🚀 Getting Started

Clone this repository and navigate to the ELK stack directory:

```bash
$ git clone https://github.com/victor-ikeme/awesome-score-spec-examples
$ cd awesome-score-spec-examples/elk-stack-example
````

This folder contains:

* `score/score.yaml`: The Score spec for the full stack
* `logstash/pipeline/logstash-nginx.config`: Logstash pipeline config
* `Makefile`: Build, test, and deploy automation
* `scripts/setup-kind-cluster.sh`: Create a local Kind cluster
* `.github/workflows/ci.yml`: GitHub Actions CI pipeline

---

## 🛠 Prerequisites

Ensure the following tools are installed:

| Tool              | Purpose                            |
| ----------------- | ---------------------------------- |
| Docker or Podman  | Container runtime                  |
| `score-compose`   | Compose backend for Score          |
| `score-k8s`       | Kubernetes backend for Score       |
| `kind`            | Local Kubernetes cluster           |
| `kubectl`         | Kubernetes CLI                     |
| `humctl`          | Humanitec CLI                      |
| Git               | Version control                    |
| Make              | (Optional) Run build/test commands |
| curl              | (Optional) Test endpoints          |
| Humanitec Account | Required for IDP-based deployments |

> 🔔 Tip: ELK can be resource-heavy. Recommend 8 GB RAM and 4 CPUs minimum for local or CI usage.

---

## 🔎 ELK Stack Overview

This example includes:

* **Elasticsearch**: The core search & analytics engine (port `9200`)
* **Logstash**: Collects and processes logs from sources like Nginx (ports `5044`, `9600`)
* **Kibana**: The UI for querying and visualizing logs (port `5601`)

All components are defined in `score.yaml`, which works **across all runtimes** with no changes.

Key Features:

* 🧾 Portable, declarative spec
* 🔁 CI-ready Makefile
* 📈 Visual logs via Kibana
* ☁️ Cloud-native ingress (DNS + Route support for Humanitec)

---

## ⚡️ Quick Start

Run everything from within the `elk-stack-example` directory.

### 🐳 Docker Compose

Fastest for local development and testing:

```bash
$ make build-and-push     # Pull ELK images
$ make compose-test       # Start the stack
```

Access Kibana at [http://localhost:5601](http://localhost:5601)

Clean up:

```bash
$ make compose-down
```

---

### ☸️ Kubernetes (Kind)

Run the stack in a local Kubernetes cluster:

```bash
$ make kind-create-cluster     # Bootstrap Kind
$ make kind-load-images        # Load ELK images into the cluster
$ make k8s-test                # Deploy the workload
```

Access Kibana at [http://localhost:5601](http://localhost:5601)

Tear down:

```bash
$ make k8s-down
```

---

### 🛠 Humanitec (Cloud-Native IDP)

Deploy to a fully-managed IDP environment using Score + Humanitec:

```bash
$ export HUMANITEC_ORG=<your-org-id>
$ export HUMANITEC_TOKEN=<your-token>
$ export HUMANITEC_APPLICATION=elk-stack-demo
$ export HUMANITEC_ENVIRONMENT=5min-local

$ make humanitec-deploy
```

Copy the URL printed in the output (e.g., `https://elk-stack-demo-qax4.localhost`) to access Kibana.

Clean up:

```bash
$ humctl delete app elk-stack-demo -e 5min-local
```

> 🌐 This is the most production-realistic deployment, complete with DNS routing and self-service infra provisioning.

---

## 🤖 CI/CD with GitHub Actions

This repo includes a CI pipeline for validating the ELK stack with `score-compose`.

The workflow does the following:

* Installs Docker & Score CLI
* Pulls Elasticsearch, Logstash, and Kibana images
* Spins up the Compose stack via Makefile
* Runs health checks on containers
* Cleans up after testing

### 🧪 Sample: `.github/workflows/ci.yml`

```yaml
name: CI
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker
        uses: docker/setup-buildx-action@v3

      - name: Install Score CLI
        run: |
          curl -fL https://github.com/score-spec/score-cli/releases/latest/download/score-linux-amd64 -o /tmp/score
          chmod +x /tmp/score
          sudo mv /tmp/score /usr/local/bin/score-compose

      - name: Pull ELK images
        run: make build-and-push

      - name: Run Compose tests
        run: make compose-test

      - name: Clean up
        if: always()
        run: make compose-down
```

To expand CI coverage:

* Add `k8s-test` and `humanitec-deploy` jobs
* Use `kind-action` to test Kubernetes in CI
* Store secrets using GitHub Actions Secrets

---

## 📖 Tutorial Series

Take a deeper dive with our 3-part blog walkthrough:

1. **[Deploy ELK Stack with Score and Docker Compose](https://your-blog.com/posts/elk-score-compose)**
   → Build a portable, local-first ELK setup.

2. **[Deploy ELK Stack with Score and Kubernetes](https://your-blog.com/posts/elk-score-k8s)**
   → Scale the same spec to a full Kubernetes cluster.

3. **[Deploy ELK Stack with Score and Humanitec](https://your-blog.com/posts/elk-score-humanitec)**
   → Move to platform-managed infra with DNS routing and self-service provisioning.

All parts reuse the same `score.yaml` — highlighting Score’s power and flexibility.

---

## 🤝 Contributing

We’d love your help expanding this project!

### 👣 How to Contribute

1. Fork this repo
2. Create a feature branch:

   ```bash
   git checkout -b feature/my-awesome-example
   ```
3. Add your workload, tests, docs
4. Submit a pull request

### ✨ Ideas for Contribution

* Add Score specs for new stacks (e.g., Kafka, MongoDB, .NET + PostgreSQL)
* Extend CI for Kubernetes and Humanitec
* Create provisioners for advanced use cases (e.g., Kafka topics, S3 buckets)
* Improve developer docs and onboarding flows

> ⭐️ Don’t forget to **star** this repo to follow updates and support the Score ecosystem!

---

## ⚖️ License

This project is licensed under the [MIT License](./LICENSE).

---

> Built with ❤️ by the platform community.
> Let’s make platform engineering composable, reusable, and delightful.

```

---

Would you like this turned into a live `README.md` preview or a shareable HTML/Markdown blog post? I can help with that too.
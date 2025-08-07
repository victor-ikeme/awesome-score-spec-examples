# ElasticSearch, Logstash, Kibana Stack Deployed With Score

Welcome to the **Awesome Score Spec Examples** repository! This project provides practical, platform-ready examples for deploying workloads using the **Score** workload specification across multiple environments: **Docker Compose**, **Kubernetes**, and **Humanitec’s Internal Developer Platform (IDP)**. Whether you’re a developer looking to simplify local development or a platform engineer building scalable infrastructure, these examples demonstrate how Score abstracts application intent from infrastructure complexity.

The repository includes examples like WordPress, SparkJava, and the **ELK stack** (Elasticsearch, Logstash, Kibana). This README focuses on the ELK stack example, showcasing how to deploy a powerful observability platform with Score, optimized for local development, Kubernetes scalability, and cloud-native production.

![ELK Stack with Score](https://res.cloudinary.com/cloudikeme/image/upload/v1754145383/cc98ebligzricim5ibey.png)

## Why Score?

Score is a declarative workload specification that separates **what** an application needs (containers, ports, resources) from **how** those needs are fulfilled (Docker, Kubernetes, or cloud platforms). Key benefits include:

- **Developer Simplicity**: Define workloads in a single `score.yaml`, reusable across environments.
- **Platform Flexibility**: Deploy to Docker Compose, Kubernetes, or Humanitec without rewriting specs.
- **CI/CD Readiness**: Automate testing and deployment with tools like GitHub Actions.
- **No YAML Handoffs**: Generate configurations automatically with `score-compose` and `score-k8s`.

Explore the ELK stack example to see Score in action!

## Table of Contents

- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [ELK Stack Example Overview](#elk-stack-example-overview)
- [Quick Start](#quick-start)
  - [Docker Compose](#docker-compose)
  - [Kubernetes](#kubernetes)
  - [Humanitec](#humanitec)
- [CI/CD with GitHub Actions](#cicd-with-github-actions)
- [Tutorial Series](#tutorial-series)
- [Contributing](#contributing)
- [License](#license)

## Getting Started

Clone the repository to explore the examples:

```bash
git clone https://github.com/victor-ikeme/awesome-score-spec-examples
cd awesome-score-spec-examples/elk-stack-example

The elk-stack-example directory contains:

score/score.yaml: The Score specification for the ELK stack.
logstash/pipeline/logstash-nginx.config: Logstash pipeline configuration.
Makefile: Commands for building, deploying, and testing.
scripts/setup-kind-cluster.sh: Script for creating a Kind cluster.
.github/workflows/ci.yml: GitHub Actions workflow for CI/CD.

Prerequisites
To run the ELK stack example, install the following tools:

Docker: Version 20.10 or later (or Podman).
score-compose: curl -fL https://github.com/score-spec/score-cli/releases/latest/download/score-linux-amd64 -o /usr/local/bin/score-compose && chmod +x /usr/local/bin/score-compose.
score-k8s: curl -fL https://github.com/score-spec/score-k8s/releases/latest/download/score-k8s-linux-amd64 -o /usr/local/bin/score-k8s && chmod +x /usr/local/bin/score-k8s.
Kind: curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64 && chmod +x ./kind && sudo mv ./kind /usr/local/bin/.
kubectl: Install via your package manager or curl.
humctl (for Humanitec): curl -Lo humctl https://github.com/humanitec/cli/releases/latest/download/humctl-linux-amd64 && chmod +x humctl && sudo mv humctl /usr/local/bin/.
Git: For cloning and contributing.
Make: Optional, for Makefile commands.
curl: For testing endpoints.
Humanitec Account: Required for Humanitec deployment (organization ID and personal access token).

Ensure sufficient system resources (e.g., 8GB RAM, 4 CPUs) for the ELK stack, especially in CI environments.
ELK Stack Example Overview
The ELK stack example deploys Elasticsearch, Logstash, and Kibana as a unified observability platform. The score.yaml defines:

Elasticsearch: Runs on port 9200 with a healthcheck.
Logstash: Processes logs (e.g., Nginx logs) on ports 5044 and 9600, with a pipeline configuration.
Kibana: Visualizes logs on port 5601, connected to Elasticsearch.

Key features:

Portable score.yaml: Works across Docker Compose, Kubernetes, and Humanitec.
Automated Testing: Makefile targets for local and CI environments.
Logstash Pipeline: Ingests sample Nginx logs for demonstration.
Cloud-Native Support: Includes DNS and route resources for Humanitec.

Quick Start
Follow these steps to deploy the ELK stack in your preferred environment. All commands are run from the elk-stack-example directory.
Docker Compose
Deploy locally with Docker Compose for development:
make build-and-push  # Pull ELK images
make compose-test    # Deploy and test

Access Kibana at http://localhost:5601. Clean up:
make compose-down

Kubernetes
Deploy to a local Kubernetes cluster using Kind:
make kind-create-cluster  # Create Kind cluster
make kind-load-images     # Load ELK images
make k8s-test             # Deploy and test

Access Kibana at http://localhost:5601. Clean up:
make k8s-down

Humanitec
Deploy to Humanitec’s IDP for cloud-native production:
export HUMANITEC_ORG=<your-org-id>
export HUMANITEC_TOKEN=<your-token>
export HUMANITEC_APPLICATION=elk-stack-demo
export HUMANITEC_ENVIRONMENT=5min-local
make humanitec-deploy

Access Kibana via the URL provided in the output (e.g., https://elk-stack-demo-qax4.localhost). Clean up:
humctl delete app elk-stack-demo -e 5min-local

CI/CD with GitHub Actions
The repository includes a GitHub Actions workflow (.github/workflows/ci.yml) to automate testing for the ELK stack in Docker Compose. The workflow:

Checks out the code.
Sets up Docker and score-compose.
Pulls ELK images.
Runs make compose-test.
Cleans up with make compose-down.

To enable CI/CD:

Push changes to a branch or main.
Monitor the workflow in the Actions tab of the repository.
Check logs for docker compose ps, container logs, and Elasticsearch healthchecks if tests fail.


Example workflow excerpt:
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
      - name: Checkout code
        uses: actions/checkout@v4
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

For Kubernetes or Humanitec testing in CI, extend the workflow with additional jobs (e.g., kind-create-cluster, humctl score deploy).
Tutorial Series
Learn how to deploy the ELK stack with Score in our comprehensive three-part series:

Deploy ELK Stack with Score and Docker Compose for Local Development: Set up a portable local environment with score-compose.
Deploy ELK Stack to Kubernetes with Score-k8s for Scalable Observability: Scale to a local Kubernetes cluster with score-k8s and Kind.
Deploy ELK Stack via Score and Humanitec with a Managed Elasticsearch Cluster: Deploy to Humanitec’s IDP for cloud-native production.

Each part uses the same score.yaml, demonstrating Score’s portability across environments.
Contributing
We welcome contributions to enhance this repository! To contribute:

Fork the repository.
Create a branch: git checkout -b feature/new-example.
Add your example or improvement (e.g., new workload, CI enhancements).
Update the README and documentation.
Submit a pull request with a clear description.

Please follow the Code of Conduct and check the Contributing Guidelines for details.
Ideas for Contributions:

Add new workload examples (e.g., MongoDB, Kafka).
Improve CI/CD workflows for Kubernetes or Humanitec.
Enhance Makefile with additional testing targets.
Write new tutorials for the series.

⭐️ Star this repo to stay updated and support the Score community!
License
This project is licensed under the MIT License. See the LICENSE file for details.

Built with ❤️ by the Score community. Explore, deploy, and contribute to make platform engineering awesome!
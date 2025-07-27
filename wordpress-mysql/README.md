# 📦 WORDPRESS-MYSQL — Deploy with Docker, Kubernetes & Score

This project is part of the [**Awesome Score Spec Examples**](https://github.com/victor-ikeme/awesome-score-spec-examples) — a curated collection of over **50 real-world Score-based applications** and deployment setups.

Here, you’ll learn how to deploy the `WORDPRESS-MYSQL` workload using the [Score Spec](https://score.dev), across **Docker**, **Podman**, and **Kubernetes** environments — **with a single `score.yaml` file.**

---

## 📖 Full Tutorial

Looking for a hands-on walkthrough?

> 📘 Check out the detailed blog post for this project:  
> 👉 [**Read the Tutorial**](<INSERT_BLOG_POST_URL_HERE>)

---

## ⚙️ Overview

| Feature            | Value                              |
|--------------------|-------------------------------------|
| 🧩 Framework        | `Wordpress/PHP`     |
| 📦 Containerized    | Yes                                |
| ☸️ Kubernetes-ready | Yes (via `score-k8s`)              |
| 🐳 Docker-ready     | Yes (via `score-compose`)          |
| 🌐 DNS Support      | Optional (`dns`, `route` resources) |

---

## 🏁 Quick Start

### 1. Clone the Repo

```bash
git clone https://github.com/victor-ikeme/awesome-score-spec-examples.git
cd awesome-score-spec-examples/wordpress-mysql
````

---

### 2. Run Locally with Docker

```bash
make compose-test     # Deploy with Docker
make compose-down     # Tear down
```

---

### 3. Run in Kubernetes

```bash
make kind-create-cluster     # (Optional) Create Kind cluster
make kind-load-images
make k8s-test
```

Your app should be accessible on `localhost` or via `kubectl port-forward`.

---

## 🔧 score.yaml at a Glance

This project uses a single `score.yaml` to describe:

* Containers & commands
* Ports and services
* Volumes and caching
* Optional DNS and route resources

Example:

```yaml
apiVersion: score.dev/v1b1
metadata:
  name: <project-name>
containers:
  web:
    image: .
    args: ["start"]
    volumes:
      - source: ${resources.source}
        target: /app
service:
  ports:
    tcp:
      port: 8080
      targetPort: 8080
resources:
  source:
    type: volume
  dns:
    type: dns
  route:
    type: route
    params:
      host: ${resources.dns.host}
      path: /
      port: 8080
```

---

## 🌐 Expose via DNS (Optional)

To get a local development hostname like `http://your-app.localhost`, enable `dns` and `route` support:

### For Docker/Podman:

```bash
score-compose init \
  --no-sample \
  --provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/dns/score-compose/10-dns-with-url.provisioners.yaml

score-compose generate score.yaml \
  --image ghcr.io/<your-image>

docker compose up -d
```

Inspect DNS outputs:

```bash
score-compose resources get-outputs dns.default#<project-name>.dns
```

---

### For Kubernetes:

```bash
score-k8s init \
  --provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/dns/score-k8s/10-dns-with-url.provisioners.yaml

score-k8s generate score.yaml \
  --image ghcr.io/<your-image>

kubectl apply -f manifests.yaml
```

Inspect outputs:

```bash
score-k8s resources get-outputs dns.default#<project-name>.dns
```

Then visit your app at the returned hostname!

---

## 📁 Project Structure

```bash
<project-name>/
├── app/                   # App source code
├── score.yaml             # Workload spec
├── Dockerfile             # Container build file
├── Makefile               # CLI commands
├── manifests.yaml         # Generated Kubernetes manifests
├── scripts/               # Cluster helpers (Kind, etc.)
└── README.md              # This file
```

---

## 📚 Related Resources

* 🏗 [Score Spec Documentation](https://score.dev/docs)
* 🐋 [score-compose](https://github.com/score-spec/score-compose)
* ☸️ [score-k8s](https://github.com/score-spec/score-k8s)
* 🧰 [Community Provisioners](https://github.com/score-spec/community-provisioners)
* 🌟 [Awesome Score Spec Examples (main repo)](https://github.com/victor-ikeme/awesome-score-spec-examples)

---

## 🙌 Credits

Maintained with ❤️ by [@victor-ikeme](https://github.com/victor-ikeme) as part of the [Awesome Score Spec Examples](https://github.com/victor-ikeme/awesome-score-spec-examples) collection.

---

## 📄 License

MIT License • See [LICENSE](../LICENSE)

```

---

### ✅ How to Use This Template

For each subproject (like `angular`, `express-api`, `fastify-server`, etc.):

1. **Copy-paste this template** into `README.md` inside the subfolder.
2. Replace placeholders:
   - `<PROJECT-NAME>` → `Angular`, `Express API`, etc.
   - `<PROJECT_FOLDER>` → `angular`, `express`, etc.
   - `<INSERT_BLOG_POST_URL_HERE>` → Link to the specific blog post
   - `<your-image>` → Docker image if available

---

Would you like me to generate README files for other folders in the repo based on this template? Just give me the folder names and blog URLs!
```

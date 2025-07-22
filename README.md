# 🌟 Awesome Score Spec Examples

Welcome to **Awesome Score Spec Examples** — a curated, ever-growing collection of real-world `score.yaml` workload specifications that demonstrate the power and flexibility of [Score.dev](https://score.dev) across use cases, stacks, and deployment targets.

Each example in this repository is structured to be deployable using:
- 🐳 [`score-compose`](https://github.com/score-spec/score-compose) (local Docker)
- ☸️ [`score-k8s`](https://github.com/score-spec/score-k8s) (Kubernetes)
- 🛠️ `humctl score` (for [Humanitec](https://humanitec.com)-based Internal Developer Platforms)

---

## 🎯 Why This Repo Exists

As a platform engineer, I wanted to:
- Collect and standardize repeatable Score-based workload patterns
- Showcase how platform tooling can be simple, clean, and declarative
- Teach others to build and deploy applications faster using Score

If you're building Internal Developer Platforms, experimenting with `score.yaml`, or just curious how to improve application delivery, you're in the right place.

---

## 🤝 Who This Repo Is For

- **Platform Engineers**: Explore patterns for consistent workload delivery
- **DevOps Professionals**: Standardize dev-to-prod transitions using Score abstractions
- **Application Developers**: Simplify deployments without worrying about environments
- **Beginners / Students**: Learn real infrastructure-as-code with simple, clean examples

> 🧑‍💻 Maintained by [Victor Ikeme](https://cloudikeme.com) — platform engineer & open source contributor to the [Score.dev](https://score.dev) community.

---

## 📦 Project Structure

Each folder is a standalone Score workload example and includes:

```


your-project/
├── score/                # Score spec + variants
│   └── score.yaml
├── app/                 # Optional: contains the app source code if applicable
├── Makefile             # Makefile used for quick deployments
├── README.md             # Details of the project and instructions
└── scripts/              # Optional automation (e.g. setup-kind-cluster.sh)

```

---

## 🗂 Table of Contents

### 📦 Single Workloads

| Project | Description |
|--------|-------------|
| [angular](./angular/) | Angular frontend workload using `score.yaml`. |
| [ml-api](./ml-api/) | Python ML microservice with REST API spec. |

### 🧩 Microservices Architectures

| Project | Description |
|--------|-------------|
| [react-java](./react-java/) | React frontend + Java backend full-stack app. |
| [traderx](./traderx/) | Stock trading simulation platform with multiple services. |
| [voting-app](./voting-app/) | Microservice voting app with REST APIs and database. |

---

## 🚀 Getting Started

You can explore each project directly by navigating to its folder.

Want to learn more about Score or how each project was built?

📝 Blog write-ups for every example are available at  
📚 **[blog.cloudikeme.com](https://blog.cloudikeme.com)**

💻 Portfolio, platform demos, and insights available at  
🌐 **[cloudikeme.com](https://cloudikeme.com)**

---

## ⭐️ Star This Repository!

If you find value here or want to support the Score ecosystem:

👉 **[Please star this repo!](https://github.com/your-username/awesome-score-spec-examples/stargazers)**  
It helps more engineers discover Score and simplifies platform adoption across teams.

---

## 🤲 Contributing

We welcome contributions from the Score and platform engineering community!

### ✅ To Contribute:

1. **Fork this repository**
2. **Add a new folder** under the root with:
   - A valid `score.yaml`
   - Optional `docker-compose.yml`, `project.meta.yaml`, and `scripts/`
   - A short `README.md` describing the example
3. **Submit a Pull Request**

> 🚫 Please do **not** run `make create` — that's for internal scaffolding only.

---

## 🔗 Helpful Resources

- 🧾 [Score.dev Documentation](https://score.dev/docs)
- 📦 [Score Compose Plugin](https://github.com/score-spec/score-compose)
- ☸️ [Score K8s Plugin](https://github.com/score-spec/score-k8s)
- 🌍 [Humanitec Score Integration](https://docs.humanitec.com/integrations/score)
- 🛠️ [Victor Ikeme’s Platform Engineering Blog](https://blog.cloudikeme.com)
- 🌐 [Portfolio & Projects](https://cloudikeme.com)

---

## 💬 License & Credits

- All projects and examples are released under the **MIT License**.
- Score is an open source project by the Score.dev community.
- This repo is a community contribution and **not officially affiliated** with Score.dev or Humanitec.

---

```
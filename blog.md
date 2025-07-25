---
title: "How to Expose Your Score Workloads with DNS and Route Resources"
description: "Learn how to expose your local and cloud-native applications using Score's dns and route resources. This guide covers both developer and platform engineer perspectives using score-compose and score-k8s."
date: 2025-07-24
author: Victor Ikeme
tags: [Score, Platform Engineering, DNS, DevOps, Tutorials]
slug: exposing-workloads-with-dns-score
canonicalUrl: https://cloudikeme.com/exposing-workloads-with-dns-score
---

# 🌐 How to Expose Your Score Workloads with DNS and Route Resources

When building modern applications using [Score](https://score.dev), one of the first challenges is exposing your service via a stable and environment-independent hostname.

This guide shows you how to request and configure `dns` and `route` resources using Score—without hardcoding values in your source code or infrastructure files.

It’s written to be **reusable across all your tutorials**, whether you’re working with Backstage, React, FastAPI, Express, or any other web-based app.

---

#### ✅ Why Use DNS and Route Resources in Score?

The `resources` section in `score.yaml` lets you declare your workload’s external dependencies (like databases or network routes) **in a portable and environment-agnostic way**.

Instead of hardcoding hostnames like `localhost:7007`, Score lets you define:

- `dns`: to request a unique local or remote hostname
- `route`: to bind that hostname to your service port and path

These are automatically handled by your platform at deploy time—no need to fiddle with Docker Compose or Kubernetes YAMLs.

---

##### 🧑‍💻 Developer Perspective

As a developer, I just want to describe *what* my app needs.  
I don’t want to worry about *how* DNS is provisioned on Docker, Kubernetes, or in CI/CD.

###### I simply define this in my `score.yaml`:

```yaml
resources:
  dns:
    type: dns

  route:
    type: route
    params:
      host: ${resources.dns.host}
      path: /
      port: 7007
```

---

##### 🧑‍🔧 Platform Engineer Perspective

As a platform engineer, I define *how* those resources are provisioned using **Score provisioners**.

Score supports this out of the box via:

* [`score-compose`](https://github.com/score-spec/community-provisioners/tree/main/dns/score-compose)
* [`score-k8s`](https://github.com/score-spec/community-provisioners/tree/main/dns/score-k8s)

You can even write your own custom provisioners!

---

## 🧱 Example: Exposing a Workload via DNS with `score-compose`

Here’s a full local workflow using Docker Compose to expose your app via Score’s DNS provisioner.

> Works with **Backstage**, but you can reuse this for *any app*.

---

### 1. Initialize Score Compose with DNS Provisioner

```bash
score-compose init \
  --no-sample \
  --provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/dns/score-compose/10-dns-with-url.provisioners.yaml
```

This sets up DNS provisioning with automatic `*.localhost` hostnames.

---

### 2. Generate `compose.yaml` from `score.yaml`

```bash
score-compose generate score.yaml \
  --image ghcr.io/mathieu-benoit/backstage:latest
```

> ✅ No need for `--publish` anymore—routing is handled via `route` + `dns`.

---

### 3. Inspect Provisioned DNS Resource

```bash
score-compose resources list

score-compose resources get-outputs dns.default#my-app.dns
```

You’ll get something like:

```json
{
  "host": "dnsjdtv57.localhost",
  "url": "http://dnsjdtv57.localhost:8080"
}
```

---

### 4. Deploy the App

```bash
docker compose up -d
```

---

### 5. Verify and Access It

```bash
docker ps
```

Visit:
[http://dnsjdtv57.localhost:8080](http://dnsjdtv57.localhost:8080)

🎉 Your app is now running at a clean, unique DNS hostname—no more port clashes or manual config tweaks.

---

## 💡 Reusable Template: DNS + Route in `score.yaml`

Here’s a generic pattern you can copy into any Score project:

```yaml
resources:
  dns:
    type: dns

  route:
    type: route
    params:
      host: ${resources.dns.host}
      path: /
      port: 8080  # Change as needed

variables:
  APP_BASE_URL: ${resources.dns.url}
```

Just plug in your image, command, and service port—and your app will be exposed cleanly across local and remote environments.

---

## 🧠 Summary

* `dns` and `route` resources allow Score workloads to be portable and environment-agnostic.
* Developers describe *what* they need; platform engineers define *how* it’s provisioned.
* Works with `score-compose`, `score-k8s`, and Humanitec orchestrators.
* No need to hardcode `localhost` or ports in your configs.

---

## 📎 Related Posts

* 🔗 [How I Use Score and Docker Compose Together in Local Dev](https://cloudikeme.com/score-compose-dev)
* 🔗 [Platform Engineering 101: Why Internal Developer Platforms Need Abstractions](https://cloudikeme.com/idp-abstractions)

---

## 🔄 Use This in Future Tutorials

In future posts, feel free to drop in this reference:

> 💡 *Need to expose your app via a custom hostname?*
> Check out [this tutorial on using Score’s `dns` and `route` resources](https://cloudikeme.com/exposing-workloads-with-dns-score).

---

Need help adapting this pattern to Kubernetes or Humanitec? Drop me a message or follow along on [GitHub](https://github.com/cloudikeme).

```

---

Would you like a custom featured image, frontmatter image link, or GitHub Gist version for embedding? I can also generate the same article for Dev.to, Hashnode, or Medium formatting if needed.
```

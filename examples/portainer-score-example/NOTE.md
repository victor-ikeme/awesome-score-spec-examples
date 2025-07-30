Of course. This is the ultimate goal: creating a single, canonical `score.yaml` that is powerful enough to define the Portainer workload and abstract enough to deploy seamlessly to both Docker Compose and Kubernetes.

The key to solving this is to combine two powerful platform engineering concepts we've already perfected:
1.  A **custom provisioner** for `score-compose` to handle the Docker socket `bind` mount.
2.  A **patch template** for `score-k8s` to apply the necessary `hostPath` volume for Kubernetes.

The developer's `score.yaml` will be beautifully simple. It will just request a resource of `type: docker-socket`. The platform engineer then provides the specific tooling (`provisioner` or `patch`) for each target environment.

Here is the complete, final project that will deploy correctly to both platforms.

---

### Project Directory: `portainer-universal`

#### 1. `score.yaml` (The Single Source of Truth)

This file is clean, portable, and defines the Portainer workload's core requirements. It declaratively requests both a standard data volume and the special Docker socket resource.

```yaml
# score.yaml
apiVersion: score.dev/v1b1
metadata:
  name: portainer-ce-demo
  annotations:
    awesome-score-spec.dev/description: "A universal Portainer CE workload for both Docker Compose and Kubernetes."
service:
  ports:
    web-ui:
      port: 9000
      targetPort: 9000
containers:
  portainer:
    image: portainer/portainer-ce:alpine
    args:
      - "-H"
      - "unix:///var/run/docker.sock"
    readinessProbe:
      httpGet:
        path: /
        port: 9000
    resources:
      requests: { cpu: "100m", memory: "128Mi" }
      limits: { cpu: "500m", memory: "256Mi" }
    volumes:
      # Mounts the standard persistent volume for Portainer's data
      /data:
        source: ${resources.portainer-data}
      # Declaratively requests access to the Docker socket
      /var/run/docker.sock:
        source: ${resources.docker-socket}
resources:
  # A standard volume for persistent data
  portainer-data:
    type: volume
  # A special resource type for the Docker socket.
  # Each platform will implement this differently.
  docker-socket:
    type: docker-socket
```

---

### Platform Tooling

These are the files the Platform Engineer provides to enable deployment on each specific platform.

#### 2. For `score-compose`: `docker-socket.provisioner.yaml`

This file teaches `score-compose` how to fulfill a request for `type: docker-socket` by generating a `bind` mount.

```yaml
# docker-socket.provisioner.yaml
- uri: template://custom-docker-socket-bind
  type: docker-socket
  outputs: |
    type: bind
    source: /var/run/docker.sock
```

#### 3. For `score-k8s`: `docker-socket.patch.tpl`

This file teaches `score-k8s` how to fulfill the same request by patching the generated `Deployment` to include a `hostPath` volume.

```go-template
# docker-socket.patch.tpl
{{- range $name, $spec := .Workloads }}
  {{- /* Find any container that uses a 'docker-socket' resource */}}
  {{- range $cname, $c := $spec.containers }}
    {{- range $_, $vol := $c.volumes }}
      {{- if contains "docker-socket" $vol.source }}
- op: add
  path: resources.deployment-{{ $name }}.spec.template.spec.volumes.-1
  value:
    name: docker-socket-volume # The name for the new volume
    hostPath:
      path: /var/run/docker.sock
      type: Socket
- op: set
  path: resources.deployment-{{ $name }}.spec.template.spec.containers.{{ $cname }}.volumeMounts
  value:
    # We must redefine all volume mounts for this container to add our new one
    - name: data-volume # Remap the original data volume
      mountPath: /data
    - name: docker-socket-volume # Add the mount for the hostPath volume
      mountPath: /var/run/docker.sock
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
```
*Note: This patch is complex because it needs to find which container requested the socket and then carefully add both a `volumes` entry and a `volumeMounts` entry to the Pod spec.*

---

#### 4. `README.md` (Explaining the Universal Deployment)

```markdown
# Universal Portainer CE Demo with Score

This project demonstrates the ultimate power of Score's portability. It defines a single, canonical `score.yaml` for a Portainer CE instance and provides the platform-specific tooling to deploy it seamlessly to **both Docker Compose and Kubernetes**.

## The Universal Workload Definition: `score.yaml`

The `score.yaml` file is the single source of truth. It is clean and abstract. The key is the `resources` block:
```yaml
resources:
  portainer-data:
    type: volume
  docker-socket:
    type: docker-socket # A custom, abstract resource type
```
The developer simply requests a standard `volume` for data and a special `docker-socket` for the privileged connection. They do not need to know how either is implemented.

---

## How to Run with `score-compose` (for Local Development)

The Platform Engineer provides a custom provisioner to handle the `docker-socket` request.

### Step 1: Initialize the Project
The `init` command registers our custom `docker-socket.provisioner.yaml`.
```bash
score-compose init --no-sample --provisioners ./docker-socket.provisioner.yaml
```

### Step 2: Generate and Launch
```bash
score-compose generate score.yaml
docker compose up -d
```
`score-compose` sees the `type: docker-socket` request, uses our provisioner, and generates the correct `bind` mount in the `docker-compose.yml`.

---

## How to Run with `score-k8s` (for Production)

The Platform Engineer provides a patch template to handle the `docker-socket` request.

### Step 1: Initialize the Project
The `init` command registers our `docker-socket.patch.tpl`.
```bash
score-k8s init --patch-templates ./docker-socket.patch.tpl
```

### Step 2: Generate and Deploy
```bash
score-k8s generate score.yaml -o manifests.yaml
kubectl apply -f manifests.yaml
```
`score-k8s` generates standard Kubernetes manifests, and then our patch template is automatically applied. It finds the Portainer `Deployment` and injects the required `hostPath` volume and `volumeMount` to grant access to the node's Docker socket.

### Conclusion

This example is the culmination of the Score philosophy. We have a single, portable `score.yaml` that clearly states the workload's needs. The platform-specific complexity is entirely encapsulated in tooling (`provisioner` or `patch`) provided by the Platform Engineer for each target environment. This enables true "define once, deploy anywhere" capability.
```
Of course. This Plex media server example is an excellent case study for handling workloads with specific, non-standard networking requirements (`network_mode: host`).

As we've established, Score is a **workload** specification. It doesn't have a direct field for `network_mode: host` because this is a highly privileged, platform-specific setting that breaks network isolation. The canonical Score approach is to define the portable aspects of the workload in `score.yaml` and then use platform-specific tooling (a patch template) to apply the special networking mode.

Here is the complete, full-fledged Score project that demonstrates this clean separation of concerns.

---

### Project Directory: `plex-server`

#### 1. `score.yaml` (The Workload Definition)

This file defines the Plex server's core requirements in a platform-agnostic way. It specifies the image, the necessary environment variables, and declaratively requests a `volume` for the media files. It intentionally omits `network_mode`.

```yaml
# score.yaml
apiVersion: score.dev/v1b1
metadata:
  name: plex-media-server
  annotations:
    awesome-score-spec.dev/description: "A Plex media server workload."
# The service.ports block is intentionally omitted.
# When using 'network_mode: host', the container's ports are directly
# exposed on the host, so Score does not need to define port mappings.
containers:
  plex:
    image: linuxserver/plex
    variables:
      VERSION: docker
    # The container mounts a volume for the media library.
    # The 'source' of this volume will be a path on the host machine,
    # provided via an environment variable.
    volumes:
      /media:
        source: ${resources.media-library}
resources:
  # This resource declaratively requests a volume for the media files.
  # The platform will fulfill this by creating a bind mount to a host path.
  media-library:
    type: volume
    # We add a 'source' parameter here to guide the provisioner/patch.
    params:
      source: ${resources.env.PLEX_MEDIA_PATH}
  # This resource allows us to source the host media path from a .env file.
  env:
    type: environment
```

#### 2. `host-networking.patch.tpl` (The Platform-Specific Patch)

This is the "magic" provided by the Platform Engineer. This patch template finds the Plex workload and applies the `network_mode: host` setting to the generated `docker-compose.yml`. It also corrects the volume to be a `bind` mount.

```go-template
# host-networking.patch.tpl
{{- range $name, $cfg := .Compose.services }}
  {{- /* Find the service that corresponds to the 'plex-media-server' workload */}}
  {{- $workloadName := dig "annotations" "compose.score.dev/workload-name" "" $cfg }}
  {{- if eq $workloadName "plex-media-server" }}
# Apply the host networking mode
- op: set
  path: services.{{ $name }}.network_mode
  value: "host"

# Find the media library volume mount and change it to a bind mount
{{- range $i, $vol := $cfg.volumes }}
  {{- if eq $vol.target "/media" }}
- op: set
  path: services.{{ $name }}.volumes.{{ $i }}
  value:
    type: bind
    # Note: This patch doesn't know the path directly.
    # The user MUST provide PLEX_MEDIA_PATH in their .env file for Docker Compose to resolve it.
    source: "${PLEX_MEDIA_PATH}"
    target: /media
  {{- end }}
{{- end }}

  {{- end }}
{{- end }}
```

#### 3. `README.md`

```markdown
# Plex Media Server with Score

This project demonstrates how to define a Plex media server, a service with special networking requirements (`network_mode: host`), using the Score specification. It highlights the separation of concerns between the portable workload definition and platform-specific settings.

## Architecture

*   **`plex-media-server` Workload**: A single-container workload that runs the Plex application. Its `score.yaml` is clean and simple.
*   **Host Networking**: The critical requirement for Plex to use host networking (for features like DLNA discovery) is **not** defined in the `score.yaml`. This is a privileged, platform-specific setting.
*   **Platform Patching**: A **patch template** (`host-networking.patch.tpl`) is used to apply the `network_mode: host` setting during the `score-compose generate` process. This is the canonical way to handle such requirements.
*   **Media Volume**: The workload declaratively requests a `volume` for its media library. The patch template and Docker Compose's `.env` file support work together to implement this as a `bind` mount to a path on the host machine.

## Key Score Concepts

*   **Separation of Concerns**: This is the core lesson. The `score.yaml` defines *what* the workload is (a Plex container needing a media volume). The platform tooling (the patch template) defines *how* it should be run on a specific platform (with host networking).
*   **Patch Templates for Privileged Settings**: Demonstrates the idiomatic Score pattern for applying non-portable, privileged configurations. The developer doesn't need to know about `network_mode`; they just deploy the "plex" workload, and the platform engineer ensures it's applied correctly.
*   **Environment-driven Configuration**: The path to the media on the host is sourced from a `.env` file, keeping the workload definition free of environment-specific details.

## How to Run

1.  **Create a media directory on your host machine:**
    ```bash
    mkdir -p ./my-media-library/movies
    ```

2.  **Create a `.env` file:**
    Copy the example and point `PLEX_MEDIA_PATH` to the absolute path of the directory you just created.
    ```bash
    cp .env.example .env
    # Edit .env and set PLEX_MEDIA_PATH to your full path, e.g., /home/user/plex-project/my-media-library
    ```

3.  **Initialize the Score Project:**
    Register the patch template with the project.
    ```bash
    score-compose init --no-sample --patch-templates ./host-networking.patch.tpl
    ```

4.  **Generate the Compose File:**
    ```bash
    score-compose generate score.yaml
    ```
    *This will generate a `compose.yaml` file and then automatically apply the patch to add `network_mode: host` and fix the volume mount.*

5.  **Launch the Application:**
    ```bash
    docker compose up -d
    ```

6.  **Access the Application:**
    Because it's using host networking, the Plex server will be available directly on your host machine's IP address at port `32400/web`. Navigate to **`http://localhost:32400/web`**.
```

#### 4. `.env.example`

```
# .env.example

# Set this to the absolute path of your media library on the host machine.
# For example: PLEX_MEDIA_PATH=/home/myuser/media
PLEX_MEDIA_PATH=
```
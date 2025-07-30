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
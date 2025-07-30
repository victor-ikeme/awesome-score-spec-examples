
# This patch applies platform-specific settings for the Pi-hole/Cloudflared stack.

# === Patch for Cloudflared service ===
{{- range $name, $cfg := .Compose.services }}
  {{- $workloadName := dig "annotations" "compose.score.dev/workload-name" "" $cfg }}
  {{- if eq $workloadName "cloudflared-dns" }}
- op: set
  path: services.{{ $name }}.networks.dns-net.ipv4_address
  value: "172.20.0.2"
  {{- end }}
{{- end }}

# === Patch for Pi-hole service ===
{{- range $name, $cfg := .Compose.services }}
  {{- $workloadName := dig "annotations" "compose.score.dev/workload-name" "" $cfg }}
  {{- if eq $workloadName "pihole-server" }}
- op: set
  path: services.{{ $name }}.cap_add
  value:
    - "NET_ADMIN"
  {{- end }}
{{- end }}
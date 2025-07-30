# traefik-labels.patch.tpl
{{- range $name, $spec := .Workloads }}
  {{- if eq $name "go-backend" }}
    {{- range $cname, $_ := $spec.containers }}
- op: set
  path: services.{{ $name }}-{{ $cname }}.labels
  value:
    {{- range $key, $val := $spec.metadata.annotations }}
    {{ $key | quote }}: {{ $val | quote }}
    {{- end }}
{{- end }}
  {{- end }}
{{- end }}
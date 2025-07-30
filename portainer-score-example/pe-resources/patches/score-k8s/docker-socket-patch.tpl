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
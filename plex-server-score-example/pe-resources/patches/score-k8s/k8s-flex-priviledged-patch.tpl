# k8s-plex-privileged.patch.tpl
{{- range $name, $spec := .Workloads }}
  {{- /* We only want to patch the 'plex-media-server' workload */}}
  {{- if eq $name "plex-media-server" }}

# Set hostNetwork to true for the Pod
- op: set
  path: resources.deployment-{{ $name }}.spec.template.spec.hostNetwork
  value: true

# Add the hostPath volume definition for the media library
- op: add
  path: resources.deployment-{{ $name }}.spec.template.spec.volumes.-1
  value:
    name: media-library-volume
    hostPath:
      # This path comes from the node's filesystem, not the user's machine.
      path: "${PLEX_MEDIA_PATH}"
      type: DirectoryOrCreate

# Update the container's volumeMount to use the new hostPath volume
{{- range $cname, $c := $spec.containers }}
- op: set
  path: resources.deployment-{{ $name }}.spec.template.spec.containers.{{ $cname }}.volumeMounts
  value:
    - name: media-library-volume
      mountPath: /media
{{- end }}
  {{- end }}
{{- end }}
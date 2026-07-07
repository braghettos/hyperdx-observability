{{/* Common name + labels */}}
{{- define "hobs.name" -}}krateo-alert-troubleshooter{{- end -}}

{{- define "hobs.labels" -}}
app.kubernetes.io/name: {{ include "hobs.name" . }}
app.kubernetes.io/part-of: hyperdx-observability
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Resolve the HyperDX admin password ONCE. Precedence:
  1. an explicit .Values.hyperdx.adminPassword
  2. the password already stored in the hyperdx-admin-creds Secret (persist across upgrades)
  3. a freshly generated, policy-compliant password (Aa1! + 32 alnum satisfies HyperDX's Zod:
     >=12 chars, upper+lower+digit+special)
Call this only from secret.yaml; everything else references the Secret via secretKeyRef so the
generated value stays stable (randAlphaNum would differ on each call).
*/}}
{{- define "hobs.adminPassword" -}}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace "hyperdx-admin-creds") -}}
{{- if .Values.hyperdx.adminPassword -}}
{{- .Values.hyperdx.adminPassword -}}
{{- else if and $existing $existing.data (index $existing.data "password") -}}
{{- index $existing.data "password" | b64dec -}}
{{- else -}}
{{- printf "Aa1!%s" (randAlphaNum 32) -}}
{{- end -}}
{{- end -}}

{{- /*
name defines a template for the name of the chartmuseum chart.

The prevailing wisdom is that names should only contain a-z, 0-9 plus dot (.) and dash (-), and should
not exceed 63 characters.

Parameters:

- .Values.nameOverride: Replaces the computed name with this given name

Usage: 'name: "{{- template "chartmuseum.name" . -}}"'
*/ -}}
{{- define "chartmuseum.name"}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
fullname defines a suitably unique name for a resource by combining
the release name and the chartmuseum chart name.

The prevailing wisdom is that names should only contain a-z, 0-9 plus dot (.) and dash (-), and should
not exceed 63 characters.

Parameters:

- .Values.fullnameOverride: Replaces the computed name with this given name

Usage: 'name: "{{- template "chartmuseum.fullname" . -}}"'
*/ -}}
{{- define "chartmuseum.fullname"}}
{{- if .Values.fullnameOverride -}}
{{-  .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name }}
{{-  .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{- /*
chartmuseum.chartref prints a chart name and version.

It does minimal escaping for use in Kubernetes labels.

Example output:

chartmuseum-0.4.5
*/ -}}
{{- define "chartmuseum.chartref" -}}
{{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}
{{- end -}}

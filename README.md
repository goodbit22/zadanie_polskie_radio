# Cel

lokalny, multi-nodemulti-node klaster k3s i wdroż w nim trzy komponenty przy pomocy Helm

1. Ingress ControllerIngress Controller (nginx-ingress)
2. MinIOMinIO jako obiektowy storage
3. nginx-frontendnginx-frontend – serwis zwracający przygotowany plik HTML z trzema obrazkami pobranymi z MinIO

## Run

### dependencies
`` make dependencies `

### Create cluster

`` make create_cluster ``

### Install charts

``make helmfile_apply  ``

## Usuwanie

### helm chart
` make clean`

### Klaster 
` make delete_cluster `
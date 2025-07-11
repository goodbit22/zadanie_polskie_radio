MINIO_VERSION := 17.0.9
NGINX_VERSION := 21.0.3
INGRESS_NGNIX_VERSION := 4.0.1
K3D_REPOSITORY:= https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh 
CLUSTER_NAME:= multiserver
HELM_CHART_MINIO_DIRECTORY := helm-chart/minio
HELM_CHART_INGRESS_DIRECTORY := helm_chart/ingress-nginx
HELM_CHART_NGINX_DIRECTORY := helm_chart/nginx-frontend
HELMFILE := helmfile.yaml


dependencies:
	@echo "Installing dependencies"
	mkdir dependencies
	k3d --version || ( curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash )
	hey -h  || sudo apt install -y hey 
	curl -L https://github.com/helmfile/helmfile/releases/download/v1.1.2/helmfile_1.1.2_linux_amd64.tar.gz | tar -xz -C dependencies 
	sudo install dependencies/helmfile /usr/bin/helmfile 
	helmfile --version 
	helm plugin install https://github.com/databus23/helm-diff
	helm plugin install helm-git
	helm plugin install s3 
	helm plugin install secrets
	wget https://dl.min.io/client/mc/release/linux-amd64/mc
	chmod +x mc
	sudo mv mc /usr/local/bin/mc

add_helm_repos:
	@echo "Adding helm repos"
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

install_helm_services:
	@echo "Installing charts"
	helm install --values=./$(HELM_CHART_MINIO_DIRECTORY)/values.yaml  minio bitnami/minio --version 17.0.9
	helm install --values=./$(HELM_CHART_INGRESS_DIRECTORY)/values.yaml ingress-nginx ingress-nginx/ingress-nginx --version 4.0.1
	helm install --values=./$(HELM_CHART_NGINX_DIRECTORY)/values.yaml nginx-frontend bitnami/nginx --version 21.0.3

create_cluster:
	@echo "Creating K3d cluster: $(CLUSTER_NAME)"
	k3d cluster create $(CLUSTER_NAME) --servers 3 --agents 3  -p "80:80@loadbalancer" -p "443:443@loadbalancer"  --k3s-arg --disable=traefik@server:0
	kubectl get nodes

start_cluster: 
	k3d cluster start "${CLUSTER_NAME}"
	kubectl get nodes     


delete_cluster:
	@echo "🗑️ Deleting K3d cluster: $(CLUSTER_NAME)"
	k3d cluster delete $(CLUSTER_NAME)

helmfile_dependencies:
	helmfile init

helmfile_apply: 
	kubectl create configmap nginx-index  -n service --from-file=./index.html
	helmfile apply
	kubectl apply -k kubernetes-manifest/

test-services:
	 hey -H "Content-Type: application/xml"

clean:
	helmfile destroy
	kubectl delete configmap nginx-index  -n service 
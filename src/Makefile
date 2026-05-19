HOME=/home/vagrant
SRC_K8S=$(HOME)/src/k8s
SRC_MANIFESTS=$(SRC_K8S)/manifests
SRC_TEMPLATES=$(SRC_K8S)/templates
PATH_TO_INIT_SQL=$(HOME)/src/services/database
NAMESPACE=service

.DEFAULT_GOAL := help

help:
	@echo "Доступные команды:"
	@echo "  make install_nginx        - Установить Ingress-Nginx Controller в кластер"
	@echo "  make install_cert         - Установить cert-manager"
	@echo "  make apply_cert           - Применить манифест cert_manager.yaml"
	@echo "  make apply_ingress        - Применить ingress.yaml и добавить запись в /etc/hosts"
	@echo "  make apply_pv             - Применить postgres-pvc.yaml (PersistentVolume)"
	@echo "  make setup_nginx          - Установить nginx на manager01 и скопировать конфиг"
	@echo "  make setup_prometheus     - Установить Prometheus (bundle.yaml + prometheus.yaml)"
	@echo "  make start                - Очистить всё, применить сервисы и запустить port-forward"
	@echo "  make clear_all            - Удалить все ресурсы и убить forwarded порты"
	@echo "  make clear_service        - Удалить все deployment, service, configmap, secret, pvc в namespace $(NAMESPACE)"
	@echo "  make apply_service        - Применить все манифесты сервисов и configmap с init.sql"
	@echo "  make kill_forwarded_ports - Остановить port-forward для gateway и session"
	@echo "  make forward_ports        - Запустить port-forward для gateway (8087) и session (8081)"

install_nginx:
	vagrant ssh manager01 -- sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.15.1/deploy/static/provider/cloud/deploy.yaml	

install_cert:
	vagrant ssh manager01 -- sudo kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.2/cert-manager.yaml

apply_cert:
	vagrant ssh manager01 -- sudo kubectl apply -f $(SRC_K8S)/cert_manager.yaml

apply_ingress:
	vagrant ssh manager01 -- sudo kubectl apply -f $(SRC_K8S)/ingress.yaml; \
	INGRESS_IP=$$(vagrant ssh manager01 -- "kubectl get ingress -n service --no-headers | awk '{print \$$4}'"); \
	vagrant ssh manager01 -- echo "$$INGRESS_IP app.do11.com" | sudo tee -a /etc/hosts

apply_pv:
	vagrant ssh manager01 -- sudo kubectl apply -f $(SRC_K8S)/postgres-pvc.yaml

setup_nginx:
	vagrant ssh manager01 -- sudo apt install nginx; \
	vagrant ssh manager01 -- cp /home/vagrant/src/services/nginx/default.conf /etc/nginx/conf.d/default.conf

setup_prometheus:
	vagrant ssh manager01 -- sudo kubectl -f --server-side $(SRC_K8S)/bundle.yaml
	vagrant ssh manager01 -- sudo kubectl -f --server-side ${SRC_K8S}/prometheus.yaml

start: clear_all apply_service forward_ports

clear_all: clear_service kill_forwarded_ports 

clear_service:
	kubectl delete deployment,service,configmap,secret,pvc --all --namespace=$(NAMESPACE)

apply_service:
	kubectl apply -f $(SRC_MANIFESTS)/namespace.yaml
	kubectl apply -f $(SRC_MANIFESTS)/configmap.yaml
	kubectl apply -f $(SRC_MANIFESTS)/secrets.yaml
		kubectl create configmap postgres-init-script \
		--from-file=$(PATH_TO_INIT_SQL)/init.sql \
		--namespace=$(NAMESPACE) || true
	kubectl apply -f $(SRC_MANIFESTS)/postgres.yaml
	kubectl apply -f $(SRC_MANIFESTS)/booking.yaml
	kubectl apply -f $(SRC_MANIFESTS)/gateway.yaml
	kubectl apply -f $(SRC_MANIFESTS)/hotel.yaml
	kubectl apply -f $(SRC_MANIFESTS)/loyalty.yaml
	kubectl apply -f $(SRC_MANIFESTS)/payment.yaml
	kubectl apply -f $(SRC_MANIFESTS)/rabbit.yaml
	kubectl apply -f $(SRC_MANIFESTS)/report.yaml
	kubectl apply -f $(SRC_MANIFESTS)/session.yaml

kill_forwarded_ports:
	-pkill -f "kubectl port-forward.*service/(session|gateway)-service"

forward_ports: kill_forwarded_ports
	kubectl port-forward -n service service/gateway-service 8087:8087&
	kubectl port-forward -n service service/session-service 8081:8081&

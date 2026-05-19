SRC_K8S=k8s
SRC_DOCKER=services
SRC_SCRIPTS=static/Part2/scripts
SRC_MANIFESTS=$(SRC_K8S)/manifests
SRC_TEMPLATES=$(SRC_K8S)/templates
PATH_TO_INIT_SQL=services/database
NAMESPACE=service

.DEFAULT_GOAL := help

help:
	@echo "Доступные команды:"
	@echo "  make start               - Полный цикл: очистка, генерация манифестов, применение, проброс портов"
	@echo "  make clear_all           - Полная очистка: удалить ресурсы K8s, убить port-forward и dashboard"
	@echo "  make clear_service       - Удалить все ресурсы (deployment, service, configmap, secret, pvc) в namespace $(NAMESPACE)"
	@echo "  make generate_manifests  - Сгенерировать .yaml из .template.yaml через envsubst (из папки templates -> manifests)"
	@echo "  make apply_service       - Применить все манифесты и создать configmap с init.sql"
	@echo "  make get_service         - Показать pods, configmaps, secrets, services в namespace $(NAMESPACE)"
	@echo "  make describe_service    - Подробное описание ресурсов"
	@echo "  make secrets             - Декодировать и показать значения секрета app-secrets"
	@echo "  make logs                - Вывести логи всех подов в namespace service"
	@echo "  make forward_ports       - Запустить port-forward для gateway (8087) и session (8081) (предварительно убивает старые процессы)"
	@echo "  make kill_forwarded_ports- Принудительно завершить все port-forward для gateway/session"
	@echo "  make up_dashboard        - Запустить minikube dashboard в фоне"
	@echo "  make kill_dashboard      - Остановить процесс minikube dashboard"
	@echo "  make build_new_dockers   - Собрать Docker-образы всех сервисов с тегом :2.0"
	@echo "  make check_time          - Замерить время переключения стратегий Recreate и RollingUpdate для gateway"

	
start: clear_all generate_manifests apply_service forward_ports

clear_all: clear_service kill_forwarded_ports kill_dashboard

clear_service:
	kubectl delete deployment,service,configmap,secret,pvc --all --namespace=$(NAMESPACE)

apply_service:
	kubectl apply -f $(SRC_MANIFESTS)/namespace.yaml
	kubectl apply -f $(SRC_MANIFESTS)/configmap.yaml
	kubectl apply -f $(SRC_MANIFESTS)/secrets.yaml
		kubectl create configmap postgres-init-script \
		--from-file=$(PATH_TO_INIT_SQL)/init.sql \
		--namespace=$(NAMESPACE)
	kubectl apply -f $(SRC_MANIFESTS)/postgres.yaml
	kubectl apply -f $(SRC_MANIFESTS)/booking.yaml
	kubectl apply -f $(SRC_MANIFESTS)/gateway.yaml
	kubectl apply -f $(SRC_MANIFESTS)/hotel.yaml
	kubectl apply -f $(SRC_MANIFESTS)/loyalty.yaml
	kubectl apply -f $(SRC_MANIFESTS)/payment.yaml
	kubectl apply -f $(SRC_MANIFESTS)/rabbit.yaml
	kubectl apply -f $(SRC_MANIFESTS)/report.yaml
	kubectl apply -f $(SRC_MANIFESTS)/session.yaml


get_service:
	kubectl get pods,configmaps,secrets,services --namespace=$(NAMESPACE)

describe_service:
	kubectl describe pods,configmap,secrets,services --namespace=$(NAMESPACE)

secrets:
	kubectl get secret app-secrets --namespace=service -o jsonpath='{.data.POSTGRES_USER}' | base64 --decode; echo

	kubectl get secret app-secrets --namespace=service -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 --decode; echo

	kubectl get secret app-secrets --namespace=service -o jsonpath='{.data.RABBIT_MQ_USER}' | base64 --decode; echo

	kubectl get secret app-secrets --namespace=service -o jsonpath='{.data.RABBIT_MQ_PASSWORD}' | base64 --decode; echo

	kubectl get secret app-secrets --namespace=service -o jsonpath='{.data.AUTH_TOKEN}' | base64 --decode; echo

logs:
	for pod in $$(kubectl get pods -n service -o name); do echo "=== $$pod ==="; kubectl logs -n service $$pod; done; echo

kill_dashboard:
	-pkill -f "minikube dashboard" || true

up_dashboard:
	minikube dashboard&

kill_forwarded_ports:
	-pkill -f "kubectl port-forward.*service/(session|gateway)-service"

forward_ports: kill_forwarded_ports
	kubectl port-forward -n service service/gateway-service 8087:8087&
	kubectl port-forward -n service service/session-service 8081:8081&

build_new_dockers:
	docker build -t xedll/gateway-service:2.0 $(SRC_DOCKER)/gateway-service
	docker build -t xedll/booking-service:2.0 $(SRC_DOCKER)/booking-service
	docker build -t xedll/hotel-service:2.0 $(SRC_DOCKER)/hotel-service
	docker build -t xedll/loyalty-service:2.0 $(SRC_DOCKER)/loyalty-service
	docker build -t xedll/payment-service:2.0 $(SRC_DOCKER)/payment-service
	docker build -t xedll/report-service:2.0 $(SRC_DOCKER)/report-service
	docker build -t xedll/session-service:2.0 $(SRC_DOCKER)/session-service

generate_manifests:
	for manifest in $$(ls $(SRC_TEMPLATES) | rev | cut -c 15- | rev); do set -a; source ${SRC_K8S}/.env; set +a; envsubst < ${SRC_TEMPLATES}/$$manifest.template.yaml > $(SRC_MANIFESTS)/$$manifest.yaml; done;

check_time:
	minikube image load xedll/gateway-service:1.0
	minikube image load xedll/gateway-service:2.0
	minikube image load xedll/gateway-service:latest

	kubectl patch deployment -n service gateway-service -p '{"spec":{"strategy":{"type":"Recreate","rollingUpdate":null}}}'

	$(SRC_SCRIPTS)/get_time_recreate.sh

	kubectl patch deployment -n service gateway-service -p '{"spec":{"strategy":{"type":"RollingUpdate"}}}'

	$(SRC_SCRIPTS)/get_time_rolling.sh

	kubectl set image deployment/gateway-service -n service gateway-service=xedll/gateway-service:latest
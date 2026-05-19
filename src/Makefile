HOME=/home/vagrant
SRC_K8S=$(HOME)/src/k8s
SRC_HELM=$(HOME)/src/helm

.DEFAULT_GOAL := help

.PHONY: help helm_apply helm_delete kustomize_apply kustomize_delete clean

help:
	@echo "Доступные команды:"
	@echo "  make helm_apply          - Упаковать Helm-чарт и установить релиз 'my-chart-test' в namespace 'test2'"
	@echo "  make helm_delete         - Удалить Helm-релиз 'my-chart-test' из namespace 'test2'"
	@echo "  make kustomize_apply     - Собрать Kustomize-оверлей (production) и применить манифесты (предварительно удалив старые)"
	@echo "  make kustomize_delete    - Удалить ресурсы, созданные предыдущим 'kustomize_apply'"
	@echo "  make clean               - Удалить сгенерированные артефакты (main.yaml, .tgz)"
	@echo "  make help                - Показать эту справку"

CHART_VERSION := $(shell helm show chart $(SRC_HELM)/my-chart | grep '^version:' | awk '{print $$2}')
CHART_ARCHIVE := $(SRC_HELM)/my-chart-$(CHART_VERSION).tgz

helm_apply: helm_delete
	sudo helm package $(SRC_HELM)/my-chart -d $(SRC_HELM)
	sudo helm install my-chart-test $(CHART_ARCHIVE) -n test2 --create-namespace
	sudo helm list -A

helm_delete:
	sudo helm uninstall my-chart-test -n test2 || true

kustomize_apply: kustomize_delete
	sudo kustomize build $(SRC_K8S)/overlays/production/ -o $(SRC_K8S)/main.yaml
	sudo kubectl apply -f $(SRC_K8S)/main.yaml
	sudo kubectl get all -n production

kustomize_delete:
	sudo kubectl delete -f $(SRC_K8S)/main.yaml || true

clean:
	sudo rm -f $(SRC_K8S)/main.yaml
	sudo rm -f $(SRC_HELM)/my-chart-*.tgz
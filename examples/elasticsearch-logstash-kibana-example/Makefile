# Disable all the default make stuff
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

## Display a list of the documented make targets
.PHONY: help
help:
	@echo Documented Make targets:
	@perl -e 'undef $$/; while (<>) { while ($$_ =~ /## (.*?)(?:\n# .*)*\n.PHONY:\s+(\S+).*/mg) { printf "\033[36m%-30s\033[0m %s\n", $$2, $$1 } }' $(MAKEFILE_LIST) | sort

.PHONY: .FORCE
.FORCE:

WORKLOAD_NAME = elk-stack
CONTAINER_NAME_ES = elasticsearch
CONTAINER_NAME_LOGSTASH = logstash
CONTAINER_NAME_KIBANA = kibana
ES_PORT_1 ?= 9200
ES_PORT_2 ?= 9300
LOG_PORT_1 ?= 5044
LOG_PORT_2 ?= 5000
LOG_PORT_3 ?= 9600
KIB_PORT ?= 5601
PUBLIC_PORT ?= 8000
REGISTRY ?= ghcr.io/victor-ikeme/awesome-score-spec-examples

## Pre-load official ELK images for the workload
.PHONY: build-and-push
build-and-push:
	@echo "Pre-loading official ELK images..."
	docker pull elasticsearch:7.16.1
	docker pull logstash:7.16.1
	docker pull kibana:7.16.1
	@echo "Images ready for use."

.score-compose/state.yaml:
	score-compose init \
		--no-sample

compose.yaml: score/score.yaml .score-compose/state.yaml Makefile
	score-compose generate score/score.yaml \
		--publish $(ES_PORT_1):$(WORKLOAD_NAME):$(ES_PORT_1) \
		--publish $(ES_PORT_2):$(WORKLOAD_NAME):$(ES_PORT_2) \
		--publish $(LOG_PORT_1):$(WORKLOAD_NAME):$(LOG_PORT_1) \
		--publish $(LOG_PORT_2):$(WORKLOAD_NAME):$(LOG_PORT_2) \
		--publish $(LOG_PORT_3):$(WORKLOAD_NAME):$(LOG_PORT_3) \
		--publish $(KIB_PORT):$(WORKLOAD_NAME):$(KIB_PORT)

## Generate a compose.yaml file from the score specs and launch it.
.PHONY: compose-up
compose-up: compose.yaml
	docker compose up --build -d --remove-orphans

## Generate a compose.yaml file from the score spec, launch it and test (curl) the exposed container.
.PHONY: compose-test
compose-test: compose-up
	sleep 5
	docker ps --all
	curl -v localhost:$(KIB_PORT)/api/status \
	
## -H "Host: $$(score-compose resources get-outputs dns.default#${WORKLOAD_NAME}.dns --format '{{ .host }}:$(KIB_PORT)')"

## Delete the containers running via compose down.
.PHONY: compose-down
compose-down:
	docker compose down -v --remove-orphans || true

## Create a local Kind cluster.
.PHONY: kind-create-cluster
kind-create-cluster:
	./scripts/setup-kind-cluster.sh

## Load ELK images into Kind cluster.
.PHONY: kind-load-images
kind-load-images:
	kind load docker-image elasticsearch:7.16.1
	kind load docker-image logstash:7.16.1
	kind load docker-image kibana:7.16.1

NAMESPACE ?= default

.score-k8s/state.yaml:
	score-k8s init \
		--no-sample

manifests.yaml: score/score.yaml .score-k8s/state.yaml Makefile
	score-k8s generate score/score.yaml

## Generate a manifests.yaml file from the score spec and apply it in Kubernetes.
.PHONY: k8s-up
k8s-up: manifests.yaml
	kubectl apply \
		-f manifests.yaml \
		-n ${NAMESPACE}
	kubectl wait deployments \
		-n ${NAMESPACE} \
		--all \
		--for condition=Available \
		--timeout=600s
	kubectl wait pods \
		-n ${NAMESPACE} \
		--all \
		--for condition=Ready \
		--timeout=600s

## Expose the Kibana container in Kubernetes via port-forward and test it, keeping ports open for browser access.
.PHONY: k8s-test
k8s-test: k8s-up
	@echo "Checking Kubernetes resources..."
	kubectl get all,httproute -n ${NAMESPACE}
	@echo "Checking pod logs for $(WORKLOAD_NAME)..."
	kubectl logs -n ${NAMESPACE} -l app.kubernetes.io/name=${WORKLOAD_NAME} -c ${CONTAINER_NAME_KIBANA} || echo "Warning: No logs available for ${CONTAINER_NAME_KIBANA}"
	@echo "Checking all pod statuses..."
	kubectl describe pods -n ${NAMESPACE}
	@echo "Testing Kibana service directly..."
	@SVC_IP=$$(kubectl get svc -n ${NAMESPACE} -l app.kubernetes.io/name=${WORKLOAD_NAME} -o jsonpath="{.items[0].spec.clusterIP}"); \
	if [ -z "$$SVC_IP" ]; then \
		echo "Error: No service found for ${WORKLOAD_NAME}"; \
		kubectl describe svc -n ${NAMESPACE}; \
		exit 1; \
	fi; \
	kubectl run -i --rm --restart=Never debug --image=curlimages/curl -n ${NAMESPACE} -- curl -v http://$$SVC_IP:$(KIB_PORT)/api/status || echo "Warning: ClusterIP test failed"
	@echo "Starting port-forward for browser access on ports $(KIB_PORT), $(ES_PORT_1), $(LOG_PORT_3)..."
	@POD_NAME=$$(kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=${WORKLOAD_NAME} -o jsonpath="{.items[0].metadata.name}"); \
	if [ -z "$$POD_NAME" ]; then \
		echo "Error: No pod found for ${WORKLOAD_NAME}"; \
		kubectl describe deployment -n ${NAMESPACE} ${WORKLOAD_NAME}; \
		exit 1; \
	fi; \
	kubectl port-forward $$POD_NAME $(KIB_PORT):$(KIB_PORT) -n ${NAMESPACE} & KIB_PID=$$!; \
	kubectl port-forward $$POD_NAME $(ES_PORT_1):$(ES_PORT_1) -n ${NAMESPACE} & ES_PID=$$!; \
	kubectl port-forward $$POD_NAME $(LOG_PORT_3):$(LOG_PORT_3) -n ${NAMESPACE} & LOG_PID=$$!; \
	sleep 2; \
	curl -v http://localhost:$(KIB_PORT)/api/status; \
	CURL_EXIT=$$?; \
	if [ $$CURL_EXIT -ne 0 ]; then \
		echo "Error: curl failed with exit code $$CURL_EXIT"; \
		kubectl describe pod $$POD_NAME -n ${NAMESPACE}; \
		kubectl logs $$POD_NAME -n ${NAMESPACE} -c ${CONTAINER_NAME_ES} || echo "Warning: No logs available for ${CONTAINER_NAME_ES}"; \
		kubectl logs $$POD_NAME -n ${NAMESPACE} -c ${CONTAINER_NAME_LOGSTASH} || echo "Warning: No logs available for ${CONTAINER_NAME_LOGSTASH}"; \
		kubectl logs $$POD_NAME -n ${NAMESPACE} -c ${CONTAINER_NAME_KIBANA} || echo "Warning: No logs available for ${CONTAINER_NAME_KIBANA}"; \
		kubectl describe pods -n ${NAMESPACE}; \
		kill $$KIB_PID $$ES_PID $$LOG_PID 2>/dev/null || true; \
		exit $$CURL_EXIT; \
	else \
		echo "Port-forwarding active. Access Kibana at http://localhost:$(KIB_PORT)/api/status, Elasticsearch at http://localhost:$(ES_PORT_1), Logstash API at http://localhost:$(LOG_PORT_3)"; \
	fi

## Delete the deployment of the local container in Kubernetes and kill port-forward processes.
.PHONY: k8s-down
k8s-down:
	kubectl delete \
		-f manifests.yaml \
		-n ${NAMESPACE} || true; \
	kill $$KIB_PID $$ES_PID $$LOG_PID 2>/dev/null || true; \
	echo "Port-forward processes terminated."

## Deploy the workloads to Humanitec.
.PHONY: humanitec-deploy
humanitec-deploy:
	humctl score deploy \
		--env ${HUMANITEC_ENVIRONMENT} \
		--app ${HUMANITEC_APPLICATION} \
		--wait

## Generate catalog-info.yaml for the workload.
.PHONY: generate-catalog-info
generate-catalog-info:
	score-k8s init \
		--no-sample \
		--provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/service/score-k8s/10-service.provisioners.yaml \
		--patch-templates https://raw.githubusercontent.com/score-spec/community-patchers/refs/heads/main/score-k8s/backstage-catalog-entities.tpl
	score-k8s generate \
		--namespace ${WORKLOAD_NAME} \
		--generate-namespace \
		score/score.yaml \
		--output catalog-info.yaml
	sed 's,$$GITHUB_REPO,victor-ikeme/awesome-score-spec-examples,g' -i catalog-info.yaml
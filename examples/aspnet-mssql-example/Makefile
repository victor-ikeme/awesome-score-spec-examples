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

WORKLOAD_NAME = aspnet-mssql
CONTAINER_NAME = aspnet
CONTAINER_IMAGE = ${CONTAINER_NAME}-image:local
NAMESPACE ?= default
PORT ?= 80


.score-compose/state.yaml:
	score-compose init \
		--no-sample

compose.yaml: score/score.yaml  .score-compose/state.yaml Makefile
	score-compose generate score/score.yaml \
		--build '${CONTAINER_NAME}={"context":"app/aspnetapp","tags":["${CONTAINER_IMAGE}"]}' \
		--publish $(PORT):$(WORKLOAD_NAME):$(PORT)

## Generate a compose.yaml file from the score specs and launch it.
.PHONY: compose-up
compose-up: compose.yaml
	docker compose up --build -d --remove-orphans

## Generate a compose.yaml file from the score spec, launch it and test (curl) the exposed container.
.PHONY: compose-test
compose-test: compose-up
	sleep 5
	docker ps --all
	curl -v localhost:80 \
		-H "Host: $$(score-compose resources get-outputs dns.default#${WORKLOAD_NAME}.dns --format '{{ .host }}:80')"

## Delete the containers running via compose down.
.PHONY: compose-down
compose-down:
	docker compose down -v --remove-orphans || true

.score-k8s/state.yaml:
	score-k8s init \
		--no-sample \
		--provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/service/score-k8s/10-service.provisioners.yaml

manifests.yaml: score/score.yaml .score-k8s/state.yaml Makefile
	score-k8s generate score/score.yaml \
		--image ${CONTAINER_IMAGE}

## Create a local Kind cluster.
.PHONY: kind-create-cluster
kind-create-cluster:
	./scripts/setup-kind-cluster.sh

NAMESPACE ?= default
## Generate a manifests.yaml file from the score spec and apply it in Kubernetes.
.PHONY: k8s-up
k8s-up: manifests.yaml
	kubectl apply \
		-f manifests.yaml \
		-n ${NAMESPACE}
	kubectl wait deployments/${WORKLOAD_NAME} \
		-n ${NAMESPACE} \
		--for condition=Available \
		--timeout=90s
	kubectl wait pods \
		-n ${NAMESPACE} \
		-l app.kubernetes.io/name=${WORKLOAD_NAME} \
		--for condition=Ready \
		--timeout=180s

## Expose the container deployed in Kubernetes via port-forward.
.PHONY: k8s-test
k8s-test: k8s-up
	sleep 5
	kubectl get all,httproute \
		-n ${NAMESPACE}
	kubectl logs \
		-l app.kubernetes.io/name=${WORKLOAD_NAME} \
		-n ${NAMESPACE}
	kubectl port-forward svc/$(WORKLOAD_NAME) $(PORT):$(PORT) -n $(NAMESPACE) &
	sleep 2
	curl -v localhost:80 \
		-H "Host: $$(score-k8s resources get-outputs dns.default#${WORKLOAD_NAME}.dns --format '{{ .host }}')"

## Delete the deployment of the local container in Kubernetes.
.PHONY: k8s-down
k8s-down:
	kubectl delete \
		-f manifests.yaml \
		-n ${NAMESPACE}

## Deploy the workloads to Humanitec.
.PHONY: humanitec-deploy
humanitec-deploy:
	humctl score deploy \
		-f score/score.yaml \
		--env ${HUMANITEC_ENVIRONMENT} \
		--app ${HUMANITEC_APPLICATION} \
		--wait

## Generate catalog-info.yaml for wordpress.
.PHONY: generate-catalog-info
generate-catalog-info:
	score-k8s init \
		--no-sample \
		--provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/service/score-k8s/10-service.provisioners.yaml \
		--patch-templates https://raw.githubusercontent.com/score-spec/community-patchers/refs/heads/main/score-k8s/backstage-catalog-entities.tpl
	score-k8s generate \
		--namespace wordpress \
		--generate-namespace \
		score/score.yaml \
		--output catalog-info.yaml
	sed 's,$$GITHUB_REPO,victor-ikeme/awesome-score-spec-examples,g' -i catalog-info.yaml
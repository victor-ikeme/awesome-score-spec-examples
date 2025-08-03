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

# Default values derived from SCORE_FILE
WORKLOAD_NAME ?= $(basename $(notdir $(SCORE_FILE)))
CONTAINER_NAME ?= $(WORKLOAD_NAME)
CONTAINER_IMAGE ?= $(CONTAINER_NAME):local
NAMESPACE ?= default
PORT ?= 80

.score-compose/state.yaml:
	score-compose init \
		--no-sample

compose.yaml: $(SCORE_FILE) .score-compose/state.yaml Makefile
	score-compose generate \
		$(SCORE_FILE) \
		--publish $(PORT):$(WORKLOAD_NAME):$(PORT)

## Generate a compose.yaml file from the score spec and launch it.
.PHONY: compose-up
compose-up: compose.yaml
	docker compose up -d --remove-orphans

## Generate a compose.yaml file from the score spec, launch it, and test (curl) the exposed container.
.PHONY: compose-test
compose-test: compose-up
	sleep 5
	docker ps --all
	curl -v localhost:$(PORT) \
		-H "Host: $$(score-compose resources get-outputs dns.default#$(WORKLOAD_NAME).dns --format '{{ .host }}:$(PORT)')"

## Delete the containers running via compose down.
.PHONY: compose-down
compose-down:
	docker compose down -v --remove-orphans || true

.score-k8s/state.yaml:
	score-k8s init \
		--no-sample \
		--provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/service/score-k8s/10-service.provisioners.yaml

manifests.yaml: $(SCORE_FILE) .score-k8s/state.yaml Makefile
	score-k8s generate \
		$(SCORE_FILE)

## Create a local Kind cluster.
.PHONY: kind-create-cluster
kind-create-cluster:
	./scripts/setup-kind-cluster.sh

## Generate a manifests.yaml file from the score spec and apply it in Kubernetes.
.PHONY: k8s-up
k8s-up: manifests.yaml
	kubectl apply \
		-f manifests.yaml \
		-n $(NAMESPACE)
	kubectl wait deployments/$(WORKLOAD_NAME) \
		-n $(NAMESPACE) \
		--for condition=Available \
		--timeout=90s
	kubectl wait pods \
		-n $(NAMESPACE) \
		-l app.kubernetes.io/managed-by=score-k8s \
		--for condition=Ready \
		--timeout=90s

## Expose the container deployed in Kubernetes via port-forward and test it.
.PHONY: k8s-test
k8s-test: k8s-up
	sleep 5
	kubectl get all,httproute \
		-n $(NAMESPACE)
	kubectl logs \
		-l app.kubernetes.io/name=$(WORKLOAD_NAME) \
		-n $(NAMESPACE)
	kubectl port-forward svc/$(WORKLOAD_NAME) $(PORT):$(PORT) -n $(NAMESPACE) &
	sleep 2
	curl -v localhost:$(PORT) \
		-H "Host: $$(score-k8s resources get-outputs dns.default#$(WORKLOAD_NAME).dns --format '{{ .host }}:$(PORT)')"

## Delete the deployment of the local container in Kubernetes.
.PHONY: k8s-down
k8s-down:
	kubectl delete \
		-f manifests.yaml \
		-n $(NAMESPACE) || true

## Deploy the workloads to Humanitec.
.PHONY: humanitec-deploy
humanitec-deploy:
	humctl score deploy \
		-f $(SCORE_FILE) \
		--env $${HUMANITEC_ENVIRONMENT:-default} \
		--app $${HUMANITEC_APPLICATION:-$(WORKLOAD_NAME)} \
		--wait

## Generate catalog-info.yaml for the workload.
.PHONY: generate-catalog-info
generate-catalog-info:
	REPO_NAME=$$(basename $$(git rev-parse --show-toplevel))
	score-k8s init \
		--no-sample \
		--provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/service/score-k8s/10-service.provisioners.yaml \
		--patch-templates https://raw.githubusercontent.com/score-spec/community-patchers/refs/heads/main/score-k8s/backstage-catalog-entities.tpl
	score-k8s generate \
		--namespace $(WORKLOAD_NAME) \
		--generate-namespace \
		$(SCORE_FILE) \
		--output catalog-info.yaml
	sed "s,$$GITHUB_REPO,victor-ikeme/$${REPO_NAME},g" -i catalog-info.yaml
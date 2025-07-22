MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

## Help: Show available commands
.PHONY: help
help:
	@echo "Available targets:"
	@grep -E '^\s*##' $(MAKEFILE_LIST) | sed -E 's/^## //' | column -t -s ':'

.PHONY: .FORCE
.FORCE:

# === Configuration ===
WORKLOAD_NAME ?= angular-demo
CONTAINER_NAME ?= web
CONTAINER_IMAGE ?= ${WORKLOAD_NAME}:test
NAMESPACE ?= default

# === Feature Flags ===
DNS_ENABLED ?= false
COMPOSE_PUBLISH ?= false
USE_PATCHES ?= false
PROVISIONERS ?= dns

# === URLs ===
DNS_COMPOSE_PROV := https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/dns/score-compose/10-dns-with-url.provisioners.yaml
DNS_K8S_PROV := https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/dns/score-k8s/10-dns-with-url.provisioners.yaml
UNPRIV_PATCH := https://raw.githubusercontent.com/score-spec/community-patchers/refs/heads/main/score-k8s/unprivileged.tpl

# === Compose ===
.score-compose/state.yaml:
ifeq ($(DNS_ENABLED),true)
	score-compose init --no-sample --provisioners $(DNS_COMPOSE_PROV)
else
	score-compose init --no-sample
endif

compose.yaml: score/score.yaml .score-compose/state.yaml Makefile
ifeq ($(COMPOSE_PUBLISH),true)
	score-compose generate score/score.yaml \
		--build '${CONTAINER_NAME}={"context":"app","tags":["${CONTAINER_IMAGE}"]}' \
		--publish 4200:${WORKLOAD_NAME}:4200
else
	score-compose generate score/score.yaml \
		--build '${CONTAINER_NAME}={"context":"app","tags":["${CONTAINER_IMAGE}"]}'
endif

## Run score-compose & launch Docker Compose services
.PHONY: compose-up
compose-up: compose.yaml
	docker compose up --build -d --remove-orphans
	sleep 3
	docker compose ps

## Show compose logs
.PHONY: compose-logs
compose-logs:
	docker compose logs -f

## curl DNS from score-compose
.PHONY: compose-test
compose-test: compose-up
	curl $$(score-compose resources get-outputs dns.default#${WORKLOAD_NAME}.dns --format '{{ .host }}:4200')

## Shut down Docker Compose
.PHONY: compose-down
compose-down:
	docker compose down -v --remove-orphans || true

# === Kubernetes ===
.score-k8s/state.yaml:
	@echo "Initializing score-k8s..."
ifeq ($(DNS_ENABLED),true)
	score-k8s init --no-sample --provisioners $(DNS_K8S_PROV)
else
	score-k8s init --no-sample
endif

manifests.yaml: score/score.yaml .score-k8s/state.yaml Makefile
ifeq ($(USE_PATCHES),true)
	score-k8s generate score/score.yaml \
		--patch-templates $(UNPRIV_PATCH) \
		--image ${CONTAINER_IMAGE}
else
	score-k8s generate score/score.yaml \
		--image ${CONTAINER_IMAGE}
endif

## Create a local kind cluster
.PHONY: kind-create-cluster
kind-create-cluster:
	./scripts/setup-kind-cluster.sh

## Load image into kind
.PHONY: kind-load-image
kind-load-image:
	kind load docker-image ${CONTAINER_IMAGE}

## Deploy to k8s
.PHONY: k8s-up
k8s-up: manifests.yaml
	kubectl apply -f manifests.yaml -n ${NAMESPACE}
	sleep 5
	kubectl get pods -n ${NAMESPACE}

## Port-forward if no DNS; else curl DNS
.PHONY: k8s-test
k8s-test: k8s-up
ifeq ($(DNS_ENABLED),true)
	curl $$(score-k8s resources get-outputs dns.default#${WORKLOAD_NAME}.dns --format '{{ .host }}')
else
	kubectl port-forward svc/${WORKLOAD_NAME} 4200:4200 -n ${NAMESPACE}
endif

## Get logs from k8s
.PHONY: k8s-logs
k8s-logs:
	kubectl logs -l app.kubernetes.io/name=${WORKLOAD_NAME} -n ${NAMESPACE} --tail=100 -f

## Shutdown k8s deployment
.PHONY: k8s-down
k8s-down:
	kubectl delete -f manifests.yaml -n ${NAMESPACE} --ignore-not-found=true
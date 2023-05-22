.PHONY: kcp-local-config
kcp-local-config:     ## Acquire local KCP kubeconfig and save it locally
	kubectl get secrets -n kcp-playground-default kcp-account -o jsonpath={.data.config} | base64 -d > .kcp/admin-stable.kubeconfig
	@echo "Local kcp config is saved under .kcp/admin-stable.kubeconfig"
	@echo "You can start using it with"
	@echo "    export KUBECONFIG=$(PWD)/.kcp/admin-stable.kubeconfig"

.PHONY: check-deps
check-deps: ## Check the dependencies needed to run the make targets
	@if ! type minikube >/dev/null; then echo 'The "minikube" command is missing: https://docs.garden.io/basics/quickstart#step-1-install-garden'; fi
	@if ! type garden >/dev/null; then echo 'The "garden" command is missing: https://docs.garden.io/basics/quickstart#step-1-install-garden'; fi
	@if ! type kubectl >/dev/null; then echo 'The "kubectl" command is missing: https://kubernetes.io/docs/tasks/tools/#kubectl'; fi

# Self-documenting Makefile
.DEFAULT_GOAL = help
.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

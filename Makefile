IMAGE_NAME = jupyterlab-ale
CONTAINER_NAME = $(IMAGE_NAME)

# Build configuration
# -------------------

APP_NAME := `sed -n 's/^ *name.*=.*"\([^"]*\)".*/\1/p' src/pyproject.toml`
APP_VERSION := `sed -n 's/^ *version.*=.*"\([^"]*\)".*/\1/p' src/pyproject.toml`
GIT_REVISION = `git rev-parse HEAD`

# Introspection targets
# ---------------------

.PHONY: help
help: header targets

.PHONY: header
header:
	@echo "\033[34mEnvironment\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@printf "\033[33m%-23s\033[0m" "APP_NAME"
	@printf "\033[35m%s\033[0m" $(APP_NAME)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "APP_VERSION"
	@printf "\033[35m%s\033[0m" $(APP_VERSION)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "GIT_REVISION"
	@printf "\033[35m%s\033[0m" $(GIT_REVISION)
	@echo "\n"

.PHONY: targets
targets:
	@echo "\033[34mDevelopment Targets\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'


.PHONY: build
build: ## build the server
	docker build -t $(IMAGE_NAME):latest .

.PHONY: run
run: ## run the server
	docker run --rm -d --name $(CONTAINER_NAME) -p 8888:8888 -v "${PWD}":/home/jovyan/work $(IMAGE_NAME)

.PHONY: start
start: ## start the container
	docker start $(CONTAINER_NAME)

.PHONY: stop
stop: ## stop container
	docker stop $(CONTAINER_NAME)

.PHONY: remove 
remove: ## remove container
	docker rm $(CONTAINER_NAME)

.PHONY: restart
restart: ## restart container
	docker restart $(CONTAINER_NAME)

.PHONY: logs
logs: ## show logs 
	docker logs $(CONTAINER_NAME)

.PHONY: shell
shell: ## execute a shell
	docker exec -it $(CONTAINER_NAME) sh -c "clear; (bash || ash || sh)"

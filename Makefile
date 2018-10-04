.PHONY: run stop tail check clean clair/* clair-scanner/* require/*

help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "\033[36m%-22s\033[0m %s\n", $$1, $$NF }' $(MAKEFILE_LIST)

##### global
CURRENT   := $(realpath .)
BINDIR    := $(realpath bin/)
CYAN      := \033[96m
RED       := \033[95m
NC        := \033[0m
OS_TYPE   := $(shell echo $(shell uname) | tr A-Z a-z)
OS_ARCH   := amd64

run: require/image ## check image
	./clair-scanner --ip=host.docker.internal $(IMAGE)

tail: ## tail -f logs clair server
	docker logs -f clair

check: ## output amount of CVE data on postgres
	@docker exec -it postgres  psql -h 127.0.0.1 -U postgres postgres -c "select COUNT(*) from vulnerability";

clean: stop clair/rmi ## stop & remove image


##### docker about clair
clair/build:
	@docker build -t sioncojp/clair-local server

clair/run: clair/build ## run clair server & postgres
	@docker run --net clair -p 5432:5432 -d --name postgres arminc/clair-db:latest
	@sleep 3
	@docker run --net=clair -p 6060-6061:6060-6061 -d --name clair sioncojp/clair-local:latest
	@echo "$(CYAN)Starting clair from scratch takes about 10 to 20 minutes for the DB to be filled up.$(NC)"
	@echo "$(CYAN)Please wait a moment.$(NC)"

clair/rm: ## rm clair server & postgres
	-@docker rm -f clair
	-@docker rm -f postgres

clair/rmi: ## rmi clair server & postgres
	-@docker rmi -f arminc/clair-db:latest
	-@docker rmi -f sioncojp/clair-localdoc


##### clair-scanner
clair-scanner/install: ## install clair-scanner cli
	-@docker run --rm -v $(PWD):/go/src/github.com/arminc/clair-scanner/bin \
		-e CGO_ENABLED=0 \
   		-e GOOS=$(OS_TYPE) \
   		-e GOARCH=$(OS_ARCH) \
		clair-scanner go build -o /go/src/github.com/arminc/clair-scanner/bin/clair-scanner


##### required
# Request target set here
.PHONY: require_*

require/image: err = $(shell echo "$(RED)you must set a argument IMAGE=xxxxx$(NC)")
require/image:
ifeq ($(IMAGE),)
define n


endef
	$(error "$n$n$(err)$n$n")
endif

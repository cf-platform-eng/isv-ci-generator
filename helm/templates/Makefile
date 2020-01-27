SHELL=/bin/bash

.PHONY: deps-test clean lint test build publish run shell needs-list needs-check
VERSION ?= latest
SRC := $(shell find . -name "*.sh") needs.json Dockerfile

<% if (dockerRepo == "") { -%>
#DOCKER_REPO := "<specify your docker repo here>"
<% } else { -%>
DOCKER_REPO := "<%= dockerRepo %>"
<% } -%>
IMAGE_NAME := "<%= testName %>"

temp/make-tags/build: $(SRC)
	docker build . --pull --tag $(IMAGE_NAME)
	mkdir -p temp/make-tags && touch temp/make-tags/build

temp/make-tags/interactive-build: Dockerfile
	docker build . --pull --tag $(IMAGE_NAME)
	mkdir -p temp/make-tags && touch temp/make-tags/interactive-build

build: temp/make-tags/build

clean:
	rm -rf temp
	docker image rm -f $(IMAGE_NAME)
	rm -rf ./logs

logs:
	mkdir -p ./logs

kubeconfig-path:
ifndef KUBECONFIG
	$(error KUBECONFIG not defined. Set this with the full path to your .kube/config file)
else
	$(NOOP)
endif

helm-chart-path:
ifndef HELM_CHART
	$(error HELM_CHART not defined. Set this with the full path to your 'helm install'able chart)
else
	$(NOOP)
endif

runtime-deps: kubeconfig-path helm-chart-path

publish: build
	docker tag $(IMAGE_NAME) $(DOCKER_REPO)/$(IMAGE_NAME):${VERSION}
	docker push $(DOCKER_REPO)/$(IMAGE_NAME):${VERSION}

run: runtime-deps build logs
	set -o pipefail; docker run \
	-e KUBECONFIG=/input/kubeconfig \
	-v ${KUBECONFIG}:/input/kubeconfig \
	-v ${HELM_CHART}:/input/helm-chart \
	$(IMAGE_NAME) 2>&1 | tee ./logs/$(shell date "+%Y.%m.%d-%H.%M.%S").log

shell: temp/make-tags/interactive-build
	docker run -it \
	-e KUBECONFIG=/input/kubeconfig \
	-v ${KUBECONFIG}:/input/kubeconfig \
	-v ${HELM_CHART}:/input/helm-chart \
	-v ${PWD}:/test \
	$(IMAGE_NAME) \
	shell

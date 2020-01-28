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
	rm -rf ./temp
	rm -rf ./logs
	docker image rm -f $(IMAGE_NAME)

logs:
	mkdir -p ./logs

publish: build
	docker tag $(IMAGE_NAME) $(DOCKER_REPO)/$(IMAGE_NAME):latest
	docker push $(DOCKER_REPO)/$(IMAGE_NAME):latest

run: build logs
	set -o pipefail; docker run \
	-e GREETING_NAME \
	$(IMAGE_NAME) 2>&1 | tee ./logs/$(shell date "+%Y.%m.%d-%H.%M.%S").log

shell: temp/make-tags/interactive-build
	docker run -it \
	-e GREETING_NAME \
	$(IMAGE_NAME) \
	shell

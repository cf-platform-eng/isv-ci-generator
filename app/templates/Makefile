SHELL=/bin/bash

# TODO phonies
IMAGE_TAG := "<%= testName %>"
BASH_SRC := $(shell find . -name "*.sh")
SRC := $(BASH_SRC) needs.json Dockerfile
TEST_SRC := $(shell find . -name "*.bats")

temp/test-helpers.bash:
	mkdir -p temp
	# TODO: this does not feel right.. (but it should be versioned)
	curl https://raw.githubusercontent.com/cf-platform-eng/isv-ci-toolkit/6c2663a08b20849a1047b6834a8feaa20e2e728f/tools/test-helpers.bash > temp/test-helpers.bash

temp/bats-mock.bash:
	mkdir -p temp
	curl https://raw.githubusercontent.com/cf-platform-eng/bats-mock/master/src/bats-mock.bash > temp/bats-mock.bash

BATS_INSTALLED := $(shell command -v bats 2>&1 > /dev/null; echo $$?)
SHELLCHECK_INSTALLED := $(shell command -v shellcheck 2>&1 > /dev/null; echo $$?)

deps-test:
ifneq ($(BATS_INSTALLED),0)
  $(warning 'bats' not installed. See https://github.com/bats-core/bats-core)
  MISSING := 1
endif
ifneq ($(SHELLCHECK_INSTALLED),0)
  $(warning 'shellcheck' not installed. See https://www.shellcheck.net/)
  MISSING := 1
endif
ifdef MISSING
  $(error "Please install missing dependencies")
endif

clean:
	rm -rf temp
	docker image rm -f $(IMAGE_TAG)
	rm -rf ./logs

temp/make-tags/lint: $(BASH_SRC)
	shellcheck *.sh
	mkdir -p temp/make-tags && touch temp/make-tags/lint

lint: temp/make-tags/lint

temp/make-tags/test: temp/bats-mock.bash temp/test-helpers.bash $(BASH_SRC) $(TEST_SRC)
	bats --tap *.bats
	mkdir -p temp/make-tags && touch temp/make-tags/test

test: deps-test temp/make-tags/lint temp/make-tags/test

temp/make-tags/build: temp/make-tags/lint temp/make-tags/test $(SRC)
	docker build . --tag $(IMAGE_TAG)
	mkdir -p temp/make-tags && touch temp/make-tags/build

build: temp/make-tags/build

run-deps: build

logs:
	mkdir -p ./logs

run: run-deps logs temp/make-tags/build
	set -o pipefail; docker run \
	-e GREETING_NAME \
	$(IMAGE_TAG) 2>&1 | tee ./logs/$(shell date "+%Y.%m.%d-%H.%M.%S").log

define run-docker-interactive
	docker run -it \
	-e GREETING_NAME \
	-v ${PWD}:/test \
	$(IMAGE_TAG) \
	$1 $2
endef

shell: temp/make-tags/build
	$(call run-docker-interactive,"/bin/bash")

needs-list:
	$(call run-docker-interactive,/bin/bash,-c "needs list")

needs-check:
	$(call run-docker-interactive,/bin/bash,-c "needs check")

.PHONY: test-skeleton test-skeleton-generator-result test deps clean test-skeleton test-skeleton-features test-helm test-helm-features deps-go-binary

#### BUILDS ####
SRC = $(shell find ./app -name "*.js" | grep -v "\.test\.")
TEST_SRC = $(shell find ./app -name "*.js" | grep "\.test\.")

test-js: deps
	npm test

#### deps ####
temp/make-tags/deps: package.json
	npm install
	npm link
	mkdir -p temp/make-tags
	touch temp/make-tags/deps

YEOMAN_INSTALLED := $(shell command -v yo 2>&1 > /dev/null; echo $$?)

deps-yeoman:
ifneq ($(YEOMAN_INSTALLED),0)
	npm install -g yo
endif
ifeq ($(USER),root)
	# avoid root check in Yeoman https://github.com/yeoman/yo/issues/348
	sed -i -e '/rootCheck/d' "$$(npm root -g)/yo/lib/cli.js"
endif

deps:  deps-yeoman temp/make-tags/deps

#### UNIT TESTS ####
temp/make-tags/lint: deps $(SRC)
	npm run lint

lint: temp/make-tags/lint

test-unit: lint test-js lint-go

#### FEATURE TESTS ####
features/temp/test-helpers.bash:
	mkdir -p features/temp
	# TODO: this does not feel right.. (but it should be versioned)
	curl https://raw.githubusercontent.com/cf-platform-eng/isv-ci-toolkit/6c2663a08b20849a1047b6834a8feaa20e2e728f/tools/test-helpers.bash > features/temp/test-helpers.bash

features/temp/bats-mock.bash:
	mkdir -p features/temp
	curl https://raw.githubusercontent.com/cf-platform-eng/bats-mock/master/src/bats-mock.bash > features/temp/bats-mock.bash

BATS_INSTALLED := $(shell command -v bats 2>&1 > /dev/null; echo $$?)
SHELLCHECK_INSTALLED := $(shell command -v shellcheck 2>&1 > /dev/null; echo $$?)

deps-features: temp/make-tags/deps features/temp/bats-mock.bash features/temp/test-helpers.bash
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

remove-generated-projects:
	rm -rf features/temp/fixture

test-skeleton-features: deps-features
	cd features && bats --tap skeleton.bats

#### TEST ####

# This target is necessary to speed up our feature tests
# This stops the timestamps being regenerated and causing
# the dockerfile to be rebuilt

test-skeleton: test-unit test-skeleton-features

test-helm: test-unit test-helm-features

test: test-unit test-helm-features test-skeleton-features

#### clean ####
clean: clean-go
	rm -rf temp/*

#### Goerkin feture tests ####

GO-VER = go1.13

# #### GO Binary Management ####
deps-go-binary:
	echo "Expect: $(GO-VER)" && \
		echo "Actual: $$(go version)" && \
	 	go version | grep $(GO-VER) > /dev/null

HAS_GO_IMPORTS := $(shell command -v goimports;)

deps-goimports: deps-go-binary
ifndef HAS_GO_IMPORTS
	go get -u golang.org/x/tools/cmd/goimports
endif

clean-go: deps-go-binary
	rm -rf build/*
	go clean --modcache

deps-go: deps-goimports deps-go-binary
	go mod download

test-helm-features: deps deps-go
	ginkgo -tags feature -r features

lint-go: deps-goimports
	git ls-files | grep '.go$$' | xargs goimports -l -w
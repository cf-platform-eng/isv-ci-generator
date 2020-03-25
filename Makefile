.PHONY: test-skeleton test-skeleton-features
.PHONY: test-helm test-helm-features
.PHONY: deps clean test

#### BUILDS ####
SRC = $(shell find ./app -name "*.js" | grep -v "\.test\.")
TEST_SRC = $(shell find ./app -name "*.js" | grep "\.test\.")

#### deps ####
YEOMAN_INSTALLED := $(shell command -v yo 2>&1 > /dev/null; echo $$?)

deps-yeoman:
ifneq ($(YEOMAN_INSTALLED),0)
	npm install yo -g
endif
ifeq ($(USER),root)
	# avoid root check in Yeoman https://github.com/yeoman/yo/issues/348
	sed -i -e '/rootCheck/d' "$$(npm root -g)/yo/lib/cli.js"
endif

temp/make-tags/deps: package.json
	npm install
	npm link
	mkdir -p temp/make-tags
	touch temp/make-tags/deps

deps: temp/make-tags/deps deps-yeoman

#### UNIT TESTS ####
temp/make-tags/lint: deps $(SRC)
	npm run lint

lint: temp/make-tags/lint

test-js: deps
	npm test

test-unit: lint test-js

#### SMOKE TESTS ####
smoke: deps
	npm run smoke-test

#### FEATURE TESTS ####
features/temp/test-helpers.bash:
	mkdir -p features/temp
	# TODO: this does not feel right.. (but it should be versioned)
	curl https://raw.githubusercontent.com/cf-platform-eng/isv-ci-toolkit/6c2663a08b20849a1047b6834a8feaa20e2e728f/tools/test-helpers.bash > features/temp/test-helpers.bash

features/temp/bats-mock.bash:
	mkdir -p features/temp
	curl https://raw.githubusercontent.com/cf-platform-eng/bats-mock/master/src/bats-mock.bash > features/temp/bats-mock.bash

BATS_INSTALLED := $(shell command -v bats 2>&1 > /dev/null; echo $$?)

deps-features: deps features/temp/bats-mock.bash features/temp/test-helpers.bash
ifneq ($(BATS_INSTALLED),0)
  $(warning 'bats' not installed. See https://github.com/bats-core/bats-core)
  MISSING := 1
endif
ifdef MISSING
  $(error "Please install missing dependencies")
endif

remove-generated-projects:
	rm -rf features/temp/fixture

test-skeleton-features: deps-features remove-generated-projects
	bats --tap features/skeleton.bats

test-helm-features: deps-features remove-generated-projects
	PRINT_LOGS=true bats --tap features/helm.bats

#### TEST ####

# This target is necessary to speed up our feature tests
# This stops the timestamps being regenerated and causing
# the dockerfile to be rebuilt

test-skeleton: test-unit test-skeleton-features

test-helm: test-unit test-helm-features

test: test-unit test-helm-features test-skeleton-features

#### clean ####
clean:
	rm -rf temp/*

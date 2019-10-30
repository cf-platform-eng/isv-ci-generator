.PHONY: test-app test-app-generator-result test deps clean

#### BUILDS ####
SRC = $(shell find ./app -name "*.js" | grep -v "\.test\.")
TEST_SRC = $(shell find ./app -name "*.js" | grep "\.test\.")

test-app: deps
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

# TODO: make this a feature
test-app-generator-result:	deps
	mkdir -p temp
	rm -rf temp/test-example
	cd temp && yo --no-insight isv-ci test-example
	$(MAKE) -C temp/test-example test

test-unit: lint test-app

#### FEATURE TESTS ####
FEATURE_SRC := $(shell find features -name "*.bats")

features/temp/test-helpers.bash:
	mkdir -p features/temp
	# TODO: this does not feel right.. (but it should be versioned)
	curl https://raw.githubusercontent.com/cf-platform-eng/isv-ci-toolkit/6c2663a08b20849a1047b6834a8feaa20e2e728f/tools/test-helpers.bash > features/temp/test-helpers.bash

features/temp/bats-mock.bash:
	mkdir -p features/temp
	curl https://raw.githubusercontent.com/cf-platform-eng/bats-mock/master/src/bats-mock.bash > features/temp/bats-mock.bash

BATS_INSTALLED := $(shell command -v bats 2>&1 > /dev/null; echo $$?)
SHELLCHECK_INSTALLED := $(shell command -v shellcheck 2>&1 > /dev/null; echo $$?)

deps-features: deps-go
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

test-features: test-app-generator-result temp/make-tags/deps deps-features features/temp/bats-mock.bash features/temp/test-helpers.bash $(FEATURE_SRC)
	# Clean out fixtures for the test
	rm -rf features/temp/fixture
	cd features && bats --tap *.bats

#### TEST ####

test: test-unit test-features test-features-go

test-app: test-unit test-app-features

test-app-features: test-features

test-helm: test-unit test-helm-features

test-helm-features: test-features-go

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

test-features-go: deps deps-go lint-go
	ginkgo -tags feature -r features

lint-go: deps-goimports
	git ls-files | grep '.go$$' | xargs goimports -l -w
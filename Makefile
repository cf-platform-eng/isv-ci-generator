.PHONY: test-app test-app-generator-result test deps clean

#### BUILDS ####
SRC = $(shell find ./app -name "*.js" | grep -v "\.test\.")
TEST_SRC = $(shell find ./app -name "*.js" | grep "\.test\.")

test-app:	deps
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

#### TEST ####
temp/make-tags/lint: deps $(SRC)
	npm run lint

lint: temp/make-tags/lint

test-app-generator-result:	deps
	mkdir -p temp
	rm -rf temp/test-example
	cd temp && yo --no-insight isv-ci test-example
	$(MAKE) -C temp/test-example test

test: lint test-app test-app-generator-result

#### clean ####
clean:
	rm -rf temp/make-tags/*

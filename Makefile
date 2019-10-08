.PHONY: test-app test-app-generator-result test deps clean

#### BUILDS ####
SRC = $(shell find ./app -name "*.js" | grep -v "\.test\.")
TEST_SRC = $(shell find ./app -name "*.js" | grep "\.test\.")

test-app:	deps
	npm test

#### TEST ####
temp/make-tags/lint: deps $(SRC)
	npm run lint

lint: temp/make-tags/lint

test-app-generator-result:	deps
	mkdir -p temp
	rm -rf temp/test-example
	cd temp && yo isv-ci test-example
	$(MAKE) -C temp/test-example test

test: lint test-app-generator-result test-app

#### deps ####
temp/make-tags/deps: package.json
	npm install
	npm link
	mkdir -p temp/make-tags
	touch temp/make-tags/deps

deps: temp/make-tags/deps deps-yo

YO_INSTALLED := $(shell command -v yo 2>&1 > /dev/null; echo $$?)

deps-yo:
ifneq ($(YO_INSTALLED),0)
	npm install -g yo
endif

#### clean ####
clean:
	rm -rf temp/make-tags/*

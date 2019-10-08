.PHONY: test-app test-app-generator-result test

test-app:
	npm test

test-app-generator-result:
	mkdir -p temp
	rm -rf temp/test-example
	cd temp && yo isv-ci test-example
	$(MAKE) -C temp/test-example test

test: test-app-generator-result test-app

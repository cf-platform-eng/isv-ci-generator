test:
	mkdir -p temp
	rm -rf temp/test-example
	cd temp && yo isv-ci test-example
	$(MAKE) -C temp/test-example test


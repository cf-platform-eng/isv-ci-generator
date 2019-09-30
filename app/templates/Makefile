.PHONY: build clean deps lint publish run shell test

clean:
	rm -rf temp

deps: temp/make-tags/deps

temp/make-tags/deps:
	mkdir -p temp/make-tags
	touch temp/make-tags/deps
	curl https://raw.githubusercontent.com/grayhemp/bats-mock/master/src/bats-mock.bash > temp/bats-mock.bash

lint:
	shellcheck *.sh

test: deps lint
	bats --tap *.bats

build:
	docker build --pull . -t gcr.io/fe-rabbit-mq-tile-ci/<%= taskName %>

publish:
	docker push gcr.io/fe-rabbit-mq-tile-ci/<%= taskName %>

run:
	docker run -it \
		-v `pwd`/input:/input \
		-v `pwd`/output:/output \
		gcr.io/fe-rabbit-mq-tile-ci/<%= taskName %>

shell:
	docker run -it \
		-v `pwd`/input:/input \
		-v `pwd`/output:/output \
		gcr.io/fe-rabbit-mq-tile-ci/<%= taskName %> \
		/bin/bash

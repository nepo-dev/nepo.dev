#!make

all: build

build:
	./src/build-site/build-site.sh

debug-all:
	BASE_URL="file://$(shell pwd)" DEBUG="true" ./src/build-site/build-site.sh

debug:
	BASE_URL="file://$(shell pwd)" BUILD_JUST_LAST_ARTICLE="true" DEBUG="true" ./src/build-site/build-site.sh

.PHONY: build

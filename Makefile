#!make

all: build

build:
	./src/build-site/build-site.sh

debug:
	
	BASE_URL="file://$(shell pwd)" ./src/build-site/build-site.sh

.PHONY: build

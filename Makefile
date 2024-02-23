TARGETS := $(shell ls scripts)


VERSION ?= latest

IMAGE_REPO ?= ghcr.io/mirantiscontainers
IMAGE_TAG_BASE ?= $(IMAGE_REPO)/helm-controller

# Image URL to use all building/pushing image targets
IMG ?= $(IMAGE_TAG_BASE):$(VERSION)

.dapper:
	@echo Downloading dapper
	@curl -sL https://releases.rancher.com/dapper/latest/dapper-`uname -s`-`uname -m` > .dapper.tmp
	@@chmod +x .dapper.tmp
	@./.dapper.tmp -v
	@mv .dapper.tmp .dapper

$(TARGETS): .dapper
	./.dapper $@

trash: .dapper
	./.dapper -m bind trash

trash-keep: .dapper
	./.dapper -m bind trash -k

deps: trash

docker-build:
	mkdir -p package/bin
	go build -o ./package/bin/helm-controller
	docker build -t $(IMG) package/

.DEFAULT_GOAL := ci

.PHONY: $(TARGETS)

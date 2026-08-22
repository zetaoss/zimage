REGISTRY ?= ghcr.io/zetaoss
include versions.env

ZBASE_IMAGE := $(REGISTRY)/zbase
ZDEV_IMAGE := $(REGISTRY)/zdev

.DEFAULT_GOAL := checks

.PHONY: checks preflight zbase zdev zdev-test

# Keep this order even when make is invoked with parallel jobs.
preflight:
	bash hack/preflight.sh

checks: preflight
	$(MAKE) zbase
	$(MAKE) zdev
	$(MAKE) zdev-test

zbase:
	docker build \
		--tag $(ZBASE_IMAGE):$(ZBASE_VERSION) \
		--tag $(ZBASE_IMAGE):latest \
		./zbase

zdev:
	docker build \
		--build-arg ZBASE_VERSION=$(ZBASE_VERSION) \
		--tag $(ZDEV_IMAGE):$(ZDEV_VERSION) \
		--tag $(ZDEV_IMAGE):latest \
		./zdev

zdev-test:
	docker build \
		--build-arg ZDEV_IMAGE=$(ZDEV_IMAGE):$(ZDEV_VERSION) \
		--file ./zdev/Dockerfile.test \
		--tag $(ZDEV_IMAGE):$(ZDEV_VERSION)-test \
		./zdev

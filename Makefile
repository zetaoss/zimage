REGISTRY ?= ghcr.io/zetaoss
include versions.env

ZBASE_IMAGE := $(REGISTRY)/zbase
ZDEV_IMAGE := $(REGISTRY)/zdev

.DEFAULT_GOAL := build

.PHONY: build zbase zdev

# Keep this order even when make is invoked with parallel jobs.
build: zbase
	$(MAKE) zdev

zbase:
	docker build \
		--tag $(ZBASE_IMAGE):$(ZBASE_VERSION) \
		--tag $(ZBASE_IMAGE):latest \
		./zbase

zdev:
	docker build \
		--tag $(ZDEV_IMAGE):$(ZDEV_VERSION) \
		--tag $(ZDEV_IMAGE):latest \
		./zdev

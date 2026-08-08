COMPRESS ?= none
IMAGE_NAME := $(shell basename $(CURDIR))-app
CONTAINER_NAME := app
DOCKER_COMPOSE := docker compose
RELEASE_DATE := sed -n 's/^PRETTY_NAME=".*\.\([0-9]\{8\}\)"$$/\1/p' /etc/os-release
EXPORT_PREFIX := export-al2023_
ifeq ($(COMPRESS), xz)
COMPRESS_CMD := xz -c -
ARCHIVE_EXT := .tar.xz
else ifeq ($(COMPRESS), gzip)
COMPRESS_CMD := gzip -c -
ARCHIVE_EXT := .tar.gz
else ifeq ($(COMPRESS), none)
COMPRESS_CMD := cat
ARCHIVE_EXT := .tar
else
$(error Invalid compression method: $(COMPRESS))
endif

default: help

help:
	@echo "Usage: make <target> [COMPRESS=<compression method>]"
	@echo "Targets:"
	@echo "  build - Build the Docker image"
	@echo "  image - dockerイメージをアーカイブファイルにエクスポート"
	@echo "  clean - 生成したアーカイブファイルを削除"
	@echo "Compression methods:"
	@echo "  xz - xz圧縮"
	@echo "  gzip - gzip圧縮"
	@echo "  指定なし（デフォルト） - 圧縮なし"
.PHONY: help

DOCKER_COMPOSE_UP := $(DOCKER_COMPOSE) up -d
DOCKER_COMPOSE_RUN := $(DOCKER_COMPOSE) run --rm $(CONTAINER_NAME)
up:
	$(DOCKER_COMPOSE_UP)
.PHONY: up

down:
	$(DOCKER_COMPOSE) down
.PHONY: down

bash:

	docker run --rm $(IMAGE_NAME) bash
.PHONY: bash

build:
	$(DOCKER_COMPOSE) build
.PHONY: build

image:
	$(DOCKER_COMPOSE) up -d && \
	CONTAINER_ID=$$($(DOCKER_COMPOSE) ps -q) && \
	RELEASE_DATE=$$($(DOCKER_COMPOSE) run --rm app $(RELEASE_DATE)) && \
	docker export $$CONTAINER_ID | $(COMPRESS_CMD) > ./$(EXPORT_PREFIX)$${RELEASE_DATE}$(ARCHIVE_EXT) && \
	$(DOCKER_COMPOSE) down
.PHONY: image

clean:
	rm -f ./$(EXPORT_PREFIX)*
.PHONY: clean

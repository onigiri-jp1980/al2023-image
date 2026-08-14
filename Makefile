COMPOSE_FILE := $(if $(COMPOSE),compose.$(COMPOSE).yml,compose.yml)

set_env_vars_base := USER_NAME=$(shell id -un) USER_ID=$(shell id -u) GROUP_ID=$(shell id -g) GROUP_NAME=$(shell id -gn)
set_env_vars := $(set_env_vars_base) COMPOSE_FILE=$(COMPOSE_FILE)

COMPRESS ?= none
IMAGE_NAME := $(shell basename $(CURDIR))-app
CONTAINER_NAME := app
# Docker Composeのコマンドを定義
DOCKER_COMPOSE := $(set_env_vars) docker compose
DOCKER_COMPOSE_UP := $(DOCKER_COMPOSE) up -d
DOCKER_COMPOSE_RUN := $(DOCKER_COMPOSE) run --rm $(CONTAINER_NAME)

# ビルドオプションを定義
OPTIONS := 
# リリース日を取得するコマンドを定義
RELEASE_DATE := sed -n 's/^PRETTY_NAME=".*\.\([0-9]\{8\}\)"$$/\1/p' /etc/os-release
EXPORT_DATE := $(shell date +%Y%m%d)
EXPORT_PREFIX := export-al2023_
ifeq ($(COMPRESS), xz) # xz圧縮
COMPRESS_CMD := xz -c -
ARCHIVE_EXT := .tar.xz
else ifeq ($(COMPRESS), gzip) # gzip圧縮
COMPRESS_CMD := gzip -c -
ARCHIVE_EXT := .tar.gz
else ifeq ($(COMPRESS), none) # 圧縮なし
COMPRESS_CMD := cat
ARCHIVE_EXT := .tar
else
$(error Invalid compression method: $(COMPRESS)) # 圧縮方法が無効な場合
endif

default: help

help:
	@echo "Usage: make <target> [COMPRESS=<compression method>] [OPTIONS=<build options>]"
	@echo "Targets:"
	@echo "  build - Build the Docker image"
	@echo "  image - dockerイメージをアーカイブファイルにエクスポート"
	@echo "  clean - 生成したアーカイブファイルを削除"
	@echo "Compression methods:"
	@echo "  xz - xz圧縮"
	@echo "  gzip - gzip圧縮"
	@echo "  指定なし（デフォルト） - 圧縮なし"
.PHONY: help

up:
	$(DOCKER_COMPOSE_UP)
.PHONY: up

down:
	$(DOCKER_COMPOSE) down
.PHONY: down

bash:

	docker run -it --rm $(IMAGE_NAME) bash
.PHONY: bash

build:
	$(DOCKER_COMPOSE) build ${OPTIONS}
.PHONY: build

image:
	$(DOCKER_COMPOSE) up -d && \
	CONTAINER_ID=$$($(DOCKER_COMPOSE) ps -q) && \
	RELEASE_DATE=$$($(DOCKER_COMPOSE) run --rm app $(RELEASE_DATE)) && \
	docker export $$CONTAINER_ID | $(COMPRESS_CMD) > ./$(EXPORT_PREFIX)$${RELEASE_DATE}_$(EXPORT_DATE)$(ARCHIVE_EXT) && \
	$(DOCKER_COMPOSE) down
.PHONY: image

clean:
	rm -f ./$(EXPORT_PREFIX)*
.PHONY: clean

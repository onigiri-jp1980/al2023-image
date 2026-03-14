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
	$(error "Invalid compression method: $(COMPRESS)")
endif

default: help

help:
	@echo "Usage: make <target> [COMPRESS=<compression method>]"
	@echo "Targets:"
	@echo "  build - Build the Docker image"
	@echo "  export-image - dockerイメージをアーカイブファイルにエクスポート"
	@echo "Compression methods:"
	@echo "  xz - xz圧縮"
	@echo "  gzip - gzip圧縮"
	@echo "  指定なし（デフォルト） - 圧縮なし"
.PHONY: help

build:
	docker compose build
.PHONY: build

export-image:
	docker compose up -d && \
	CONTAINER_ID=$$(docker compose ps -q) && \
	docker export $$CONTAINER_ID | $(COMPRESS_CMD) > ./export$(ARCHIVE_EXT) && \
	docker compose down
.PHONY: export-image
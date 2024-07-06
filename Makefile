# Copyright (c) Alexandre Gomes Gaigalas <alganet@gmail.com>
# SPDX-License-Identifier: ISC

IMAGE = alganet/shell-versions:all

.PHONY: help docker-matrix

help:
	@echo "Usage: make docker-matrix"

docker-matrix:
	@docker run -t --rm \
		-v $(PWD):/opt/coral \
		-w /opt/coral \
		$(IMAGE) \
			sh test/matrix -c "./entrypoint.sh tap 'test/*/*'"

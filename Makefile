






REMOTE_HOST = rmann@latencyzero.com
IMAGE_NAME = bingo:latest



run-local: rename-old-container
	docker run										\
		--name bingo								\
		-p 8080:8080								\
		-v /Users/rmann/Desktop/BingoData:/data		\
		-e DATA_DIR=/data							\
		-e LOG_LEVEL=debug							\
		$(IMAGE_NAME)

rename-old-container:
	@if docker ps -a --format '{{.Names}}' | grep -q "^bingo$$"; then		\
		echo "Renaming old bingo container...";								\
		docker rename bingo bingo-old-$$(date +%s);							\
	fi

build-local:
	DOCKER_BUILDKIT=1 docker build -t bingo .

build-intel:
	DOCKER_BUILDKIT=1 docker build --platform=linux/amd64 -t bingo .

push:
	docker save $(IMAGE_NAME) | gzip | ssh $(REMOTE_HOST) "gunzip | docker load"

REMOTE_CONTAINER = bingo

restart:
	ssh $(REMOTE_HOST) "\
		docker stop $(REMOTE_CONTAINER) || true && \
		docker rm $(REMOTE_CONTAINER) || true && \
		docker run -d --name $(REMOTE_CONTAINER) $(IMAGE_NAME)"

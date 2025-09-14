DOCKERFILE_ROUTER := router/Dockerfile.router
DOCKERFILE_HOST := host/Dockerfile.host

TAG_ROUTER := "aschiffe_r1"
TAG_HOST := "aschiffe_h1"

all: build run

build:
	docker build -t $(TAG_ROUTER) -f $(DOCKERFILE_ROUTER) .
	docker build -t $(TAG_HOST) -f $(DOCKERFILE_HOST) .

.PHONY: all build run

DOCKERFILE_ROUTER := router/Dockerfile.router
DOCKERFILE_HOST := host/Dockerfile.host

TAG_ROUTER := "aschiffe_r1"
TAG_HOST := "aschiffe_h1"

HOSTNAME_R1 := "aschiffe_host_r1"
HOSTNAME_H1 := "aschiffe_host_h1"

all: build run

build:
	docker build -t $(TAG_ROUTER) -f $(DOCKERFILE_ROUTER) .
	docker build -t $(TAG_HOST) -f $(DOCKERFILE_HOST) .

run: build
	docker run -d --hostname $(HOSTNAME_R1) --privileged $(TAG_ROUTER)
	docker run -d --hostname $(HOSTNAME_H1) --privileged $(TAG_HOST)

stop_containers:
	docker stop $(HOSTNAME_R1) || true
	docker stop $(HOSTNAME_H1) || true

delete_containers: stop_containers
	docker rm -f $(HOSTNAME_R1) || true
	docker rm -f $(HOSTNAME_H1) || true

delete_images: delete_containers
	docker rmi -f $(TAG_ROUTER) || true
	docker rmi -f $(TAG_HOST) || true

purge: delete_images

.PHONY: all build run stop_containers delete_containers delete_images purge
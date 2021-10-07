REPO := ghcr.io/stealthybox/tce-swag
TAG := latest

IMG = $(REPO):$(TAG)

build:
	docker build . -t $(IMG)

load-k3d:
	k3d image import $(IMG)

push:
	docker push $(IMG)

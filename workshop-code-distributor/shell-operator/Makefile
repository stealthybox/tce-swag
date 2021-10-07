TAG := dev

build-dev:
	docker build . -t ghcr.io/stealthybox/code-distributor:$(TAG)
	k3d image import ghcr.io/stealthybox/code-distributor:$(TAG)

build:
	docker build . -t ghcr.io/stealthybox/code-distributor

push:
	docker push ghcr.io/stealthybox/code-distributor

deploy:
	kubectl apply -f ./k8s/

IMAGE_ROOT?=ghcr.io/biodt
IMAGE=forest-bird
IMAGE_VERSION=0.3.0
R_VERSION=4.3.3


build: Dockerfile
	docker buildx build --platform linux/amd64 \
		--label "org.opencontainers.image.source=https://github.com/BioDT/uc-forest-bird" \
		--label "org.opencontainers.image.description=Forest-bird environment with R $(R_VERSION)" \
		--build-arg R_VERSION=$(R_VERSION) \
		-t $(IMAGE_ROOT)/$(IMAGE):$(IMAGE_VERSION) \
		.

push:
	docker push $(IMAGE_ROOT)/$(IMAGE):$(IMAGE_VERSION)

singularity:
	rm -f $(IMAGE).sif $(IMAGE).tar
	docker save $(IMAGE_ROOT)/$(IMAGE):$(IMAGE_VERSION) -o $(IMAGE).tar
	singularity build $(IMAGE).sif docker-archive://$(IMAGE).tar
	rm -f $(IMAGE).tar

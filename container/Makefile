IMAGE_ROOT?=ghcr.io/biodt
IMAGE=landis
IMAGE_VERSION=0.2.1


build: Dockerfile
	docker build \
		--label "org.opencontainers.image.source=https://github.com/BioDT/uc-forest-bird" \
		--label "org.opencontainers.image.description=LANDIS-II v7 environment" \
		-t ${IMAGE_ROOT}/${IMAGE}:${IMAGE_VERSION} \
		.

push:
	docker push ${IMAGE_ROOT}/${IMAGE}:${IMAGE_VERSION}

singularity:
	rm -f $(IMAGE).sif $(IMAGE).tar
	docker save $(IMAGE_ROOT)/$(IMAGE):$(IMAGE_VERSION) -o $(IMAGE).tar
	singularity build $(IMAGE).sif docker-archive://$(IMAGE).tar
	rm -f $(IMAGE).tar

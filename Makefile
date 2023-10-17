IMAGE_ROOT?=localhost
IMAGE=landis
SIF=${IMAGE}.sif
TAG=0.2.1

build: Dockerfile
	podman build --format docker \
		--label "org.opencontainers.image.source=https://github.com/BioDT/uc-forest-bird" \
		--label "org.opencontainers.image.description=LANDIS-II v7 environment" \
		-t ${IMAGE_ROOT}/${IMAGE}:${TAG} \
		.

push:
	podman push ${IMAGE_ROOT}/${IMAGE}:${TAG}

singularity:
	rm -f $(SIF) $(SIF:.sif=.tar)
	podman save ${IMAGE}:${TAG} -o $(SIF:.sif=.tar)
	singularity build $(SIF) docker-archive://$(SIF:.sif=.tar)
	rm -f $(SIF:.sif=.tar)

IMAGE_ROOT?=localhost
IMAGE=landis-ii
SIF=${IMAGE}.sif
TAG=0.1

build: Dockerfile
	podman build --format docker \
		-t ${IMAGE_ROOT}/${IMAGE}:${TAG} \
		.

push:
	podman push ${IMAGE_ROOT}/${IMAGE}:${TAG}

singularity:
	rm -f $(SIF) $(SIF:.sif=.tar)
	podman save ${IMAGE}:${TAG} -o $(SIF:.sif=.tar)
	singularity build $(SIF) docker-archive://$(SIF:.sif=.tar)
	rm -f $(SIF:.sif=.tar)

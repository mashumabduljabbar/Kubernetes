#!/bin/bash

# Set Image Name
export IMAGE_FRONTEND="karsajobs-ui:latest"

# Nama repo untuk backend
export REPO_FRONTEND="$USERNAME_DOCKER/$IMAGE_FRONTEND"

# Build Docker image untuk backend
docker build -t $IMAGE_FRONTEND -f Dockerfile .

# Cek Docker
docker images

# Tag Local Image dengan Docker Registry
docker tag $IMAGE_FRONTEND $REPO_FRONTEND

# Push image ke Docker Hub
docker push $REPO_FRONTEND
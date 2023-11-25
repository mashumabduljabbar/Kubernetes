#!/bin/bash

# Set username Docker Hub & Login
export USERNAME_DOCKER="mashumjabbar"
echo $PASSWORD_DOCKER_HUB | docker login -u $USERNAME_DOCKER --password-stdin

# Set Image Name
export IMAGE_BACKEND="karsajobs:latest"

# Nama repo untuk backend
export REPO_BACKEND="$USERNAME_DOCKER/$IMAGE_BACKEND"

# Build Docker image untuk backend
docker build -t $IMAGE_BACKEND -f Dockerfile .

# Cek Docker
docker images

# Tag Local Image dengan Docker Registry
docker tag $IMAGE_BACKEND $REPO_BACKEND

# Push image ke Docker Hub
docker push $REPO_BACKEND
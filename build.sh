#!/bin/bash

if [[ $(stat -c '%U' /var/run/docker.sock) != $USER ]]; then
  sudo chown $USER /var/run/docker.sock
fi

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

docker build -t makemkv-docker-build "$SCRIPT_DIR"

BUILD_ARTIFACT_EXTRACTION_CONTAINER_NAME="makemkv-artifact-extraction-container"
docker create --name "$BUILD_ARTIFACT_EXTRACTION_CONTAINER_NAME" makemkv-docker-build
docker cp "$BUILD_ARTIFACT_EXTRACTION_CONTAINER_NAME":/build-artifacts "$SCRIPT_DIR"
docker rm "$BUILD_ARTIFACT_EXTRACTION_CONTAINER_NAME"
docker system prune --force

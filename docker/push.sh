#!/bin/bash

main() {

  local IMAGE_NAME="fredlackey/aws-cleanup"
  local REGISTRY_URL="docker.fredlackey.com"
  local VERSION=$(grep -i 'LABEL version=' Dockerfile | sed 's/.*version="\([^"]*\)".*/\1/')

  if [ -z "$VERSION" ]; then
    echo "Version label not found in Dockerfile."
    exit 1
  fi

  local LOGIN_CMD="docker login $REGISTRY_URL"
  eval "$LOGIN_CMD"
  if [ $? -ne 0 ]; then
    echo "Docker login failed. Exiting."
    exit 1
  fi

  # Full image names with registry
  local IMAGE_VERSION="$REGISTRY_URL/$IMAGE_NAME:$VERSION"
  local IMAGE_LATEST="$REGISTRY_URL/$IMAGE_NAME:latest"

  # Tag the images
  local TAG_CMD_VERSION="docker tag $IMAGE_NAME:$VERSION $IMAGE_VERSION"
  local TAG_CMD_LATEST="docker tag $IMAGE_NAME:$VERSION $IMAGE_LATEST"

  echo "Tagging Docker images..."
  eval "$TAG_CMD_VERSION"
  eval "$TAG_CMD_LATEST"

  # Push the images to the custom registry
  local PUSH_CMD_VERSION="docker push $IMAGE_VERSION"
  local PUSH_CMD_LATEST="docker push $IMAGE_LATEST"

  echo "Pushing Docker images..."
  eval "$PUSH_CMD_VERSION"
  eval "$PUSH_CMD_LATEST"

  echo "Purshed Docker image..."
  eval "$CMD"
  echo ""
  echo "Docker image pushed as:"
  echo "  $IMAGE_VERSION"
  echo "  $IMAGE_LATEST:latest"

}

main "$@"
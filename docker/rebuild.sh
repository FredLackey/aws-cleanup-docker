#!/bin/bash

main() {

  local IMAGE_NAME="fredlackey/aws-cleanup"
  local VERSION=$(grep -i 'LABEL version=' Dockerfile | sed 's/.*version="\([^"]*\)".*/\1/')

  if [ -z "$VERSION" ]; then
    echo "Version label not found in Dockerfile."
    exit 1
  fi

  local CMD="docker build \
    --no-cache \
    -t $IMAGE_NAME:$VERSION \
    -t $IMAGE_NAME:latest \
    ."

  echo "Building Docker image..."
  eval "$CMD"
  echo ""
  echo "Docker image built and tagged as:"
  echo "  $IMAGE_NAME:$VERSION"
  echo "  $IMAGE_NAME:latest"


# Optionally, push the images to a Docker registry (uncomment if needed)
# docker push "$IMAGE_NAME:$VERSION"
# docker push "$IMAGE_NAME:latest"

# echo "Docker image built and tagged as $IMAGE_NAME:$VERSION and $IMAGE_NAME:latest"

}

main "$@"
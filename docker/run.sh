docker run -it --rm --net=bridge \
  -v ./data/config:/var/aws-cleanup/config \
  -v ./data/storage:/var/aws-cleanup/storage \
  fredlackey/aws-cleanup:latest \
  /bin/bash

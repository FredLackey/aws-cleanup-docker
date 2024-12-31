docker run -it --rm --net=bridge \
  -v ./data/aws:/root/.aws \
  -v ./data/output:/root/output \
  fredlackey/aws-cleanup:latest \
  /bin/bash

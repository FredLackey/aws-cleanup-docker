#! /bin/bash

get_regions() {

  local accountJson="$1"

  AWS_REGIONS=(
    "us-east-1"
    "us-east-2"
    "us-west-1"
    "us-west-2"
    "af-south-1"
    "ap-east-1"
    "ap-south-1"
    "ap-northeast-1"
    "ap-northeast-2"
    "ap-northeast-3"
    "ap-southeast-1"
    "ap-southeast-2"
    "ap-southeast-3"
    "ca-central-1"
    "eu-central-1"
    "eu-west-1"
    "eu-west-2"
    "eu-west-3"
    "eu-north-1"
    "eu-south-1"
    "me-south-1"
    "sa-east-1"
  )

  AWS_REGIONS_GOVCLOUD=(
    "us-gov-east-1"
    "us-gov-west-1"
  )

  if [ "$(is_govcloud "$accountJson")" = "true" ]; then
    echo "${AWS_REGIONS_GOVCLOUD[@]}"
  else
    echo "${AWS_REGIONS[@]}"
  fi

}

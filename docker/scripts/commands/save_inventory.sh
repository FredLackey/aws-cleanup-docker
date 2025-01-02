#! /bin/bash

save_inventory() {

  # This script is called from the cleanup script.
  # It will save various AWS resources to a folder.

  mkdir -p "$INVENTORY_FOLDER"

  # Save all EC2 instances
  if instances=$(aws ec2 describe-instances --output json) && \
     [[ $(echo "$instances" | jq '.Reservations | length') -gt 0 ]]; then
    echo "$instances" > "${INVENTORY_FOLDER}/ec2-instances.json"
  fi

  # Save all EC2 volumes where the current account is the owner
  if volumes=$(aws ec2 describe-volumes --output json) && \
     [[ $(echo "$volumes" | jq '.Volumes | length') -gt 0 ]]; then
    echo "$volumes" > "${INVENTORY_FOLDER}/ec2-volumes.json"
  fi

  # Save all EC2 snapshots where the current account is the owner
  if snapshots=$(aws ec2 describe-snapshots --owner-id "$ACCOUNT_ID" --output json) && \
     [[ $(echo "$snapshots" | jq '.Snapshots | length') -gt 0 ]]; then
    echo "$snapshots" > "${INVENTORY_FOLDER}/ec2-snapshots.json"
  fi

  # Save all EC2 AMIs where the current account is the owner
  if images=$(aws ec2 describe-images --owners "$ACCOUNT_ID" --output json) && \
     [[ $(echo "$images" | jq '.Images | length') -gt 0 ]]; then
    echo "$images" > "${INVENTORY_FOLDER}/ec2-images.json"
  fi

  # Save all users
  if users=$(aws iam list-users --output json) && \
     [[ $(echo "$users" | jq '.Users | length') -gt 0 ]]; then
    echo "$users" > "${INVENTORY_FOLDER}/iam-users.json"
  fi

  # Save all groups
  if groups=$(aws iam list-groups --output json) && \
     [[ $(echo "$groups" | jq '.Groups | length') -gt 0 ]]; then
    echo "$groups" > "${INVENTORY_FOLDER}/iam-groups.json"
  fi

  # Save all RDS instances
  if rds_instances=$(aws rds describe-db-instances --output json) && \
     [[ $(echo "$rds_instances" | jq '.DBInstances | length') -gt 0 ]]; then
    echo "$rds_instances" > "${INVENTORY_FOLDER}/rds-instances.json"
  fi

  # Save all RDS snapshots
  if rds_snapshots=$(aws rds describe-db-snapshots --output json) && \
     [[ $(echo "$rds_snapshots" | jq '.DBSnapshots | length') -gt 0 ]]; then
    echo "$rds_snapshots" > "${INVENTORY_FOLDER}/rds-snapshots.json"
  fi

  # Save all S3 buckets
  if s3_buckets=$(aws s3api list-buckets --output json) && \
     [[ $(echo "$s3_buckets" | jq '.Buckets | length') -gt 0 ]]; then
    echo "$s3_buckets" > "${INVENTORY_FOLDER}/s3-buckets.json"
  fi
}

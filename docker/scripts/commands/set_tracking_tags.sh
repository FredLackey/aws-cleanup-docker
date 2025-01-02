#! /bin/bash

set_tracking_tags() {
  echo "    Checking tracking tags..."
  
  # Get EC2 instances for current region
  instances_json=$(aws ec2 describe-instances 2>/dev/null)
  if [ $? -ne 0 ]; then
    echo "    Error: Failed to get EC2 instances."
    return 1
  fi

  # Get RDS instances for current region
  rds_instances_json=$(aws rds describe-db-instances 2>/dev/null)
  if [ $? -ne 0 ]; then
    echo "    Error: Failed to get RDS instances."
    return 1
  fi

  # Process EC2 instances
  echo "      Processing EC2 instances:"
  all_instances_json=$(echo "$instances_json" | jq -r '.Reservations[].Instances[]')
  instance_count=0
  while IFS= read -r instance; do
    instance_id=$(echo "$instance" | jq -r '.InstanceId')
    instance_name=$(echo "$instance" | jq -r '([.Tags[]? | select(.Key=="Name").Value] | first // "<unnamed>")')
    catalog_date=$(echo "$instance" | jq -r '([.Tags[]? | select(.Key=="CATALOG_DATE").Value] | first // "")')
    
    if [ -z "$catalog_date" ]; then
      echo "        - $instance_id ($instance_name): Setting CATALOG_DATE to $TIMESTAMP"
      aws ec2 create-tags --resources "$instance_id" --tags "Key=CATALOG_DATE,Value=$TIMESTAMP" --no-cli-pager >/dev/null 2>&1
      if [ $? -ne 0 ]; then
        echo "        Error: Failed to set tag for EC2 instance $instance_id"
      fi
    else
      echo "        - $instance_id ($instance_name) cataloged $catalog_date"
    fi
    instance_count=$((instance_count + 1))
  done < <(echo "$all_instances_json" | jq -c '.')
  
  if [ $instance_count -eq 0 ]; then
    echo "        No EC2 instances found."
  fi

  # Process RDS instances
  echo "      Processing RDS instances:"
  instance_count=0
  while IFS= read -r instance; do
    db_identifier=$(echo "$instance" | jq -r '.DBInstanceIdentifier')
    arn=$(echo "$instance" | jq -r '.DBInstanceArn')
    
    # Get tags for RDS instance
    tags_json=$(aws rds list-tags-for-resource --resource-name "$arn" 2>/dev/null)
    catalog_date=$(echo "$tags_json" | jq -r '([.TagList[]? | select(.Key=="CATALOG_DATE").Value] | first // "")')
    
    if [ -z "$catalog_date" ]; then
      echo "        - $db_identifier: Setting CATALOG_DATE to $TIMESTAMP"
      aws rds add-tags-to-resource --resource-name "$arn" --tags "Key=CATALOG_DATE,Value=$TIMESTAMP" --no-cli-pager >/dev/null 2>&1
      if [ $? -ne 0 ]; then
        echo "        Error: Failed to set tag for RDS instance $db_identifier"
      fi
    else
      echo "        - $db_identifier cataloged $catalog_date"
    fi
    instance_count=$((instance_count + 1))
  done < <(echo "$rds_instances_json" | jq -r '.DBInstances[]' | jq -c '.')
  
  if [ $instance_count -eq 0 ]; then
    echo "        No RDS instances found."
  fi
}

#! /bin/bash

shutdown_all_ec2() {
  echo "    Checking all EC2 instances..."
  
  # Get instances for current region
  instances_json=$(aws ec2 describe-instances 2>/dev/null)
  if [ $? -ne 0 ]; then
    echo "    Error: Failed to get instances in current region"
    return 1
  fi
  
  # Get all instances
  all_instances_json=$(echo "$instances_json" | jq -r '.Reservations[].Instances[]')
  running_instances_json=$(echo "$all_instances_json" | jq -r 'select(.State.Name=="running")')
  
  echo "    Current instance states:"
  while IFS= read -r instance; do
    instance_id=$(echo "$instance" | jq -r '.InstanceId')
    instance_name=$(echo "$instance" | jq -r '([.Tags[]? | select(.Key=="Name").Value] | first // "<unnamed>")')
    instance_state=$(echo "$instance" | jq -r '.State.Name')
    echo "        - $instance_id ($instance_name) - $instance_state"
  done < <(echo "$all_instances_json" | jq -c '.')
  
  if [ ! -z "$running_instances_json" ]; then
    echo -e "\n    Stopping running instances:"
    while IFS= read -r instance; do
      instance_id=$(echo "$instance" | jq -r '.InstanceId')
      instance_name=$(echo "$instance" | jq -r '([.Tags[]? | select(.Key=="Name").Value] | first // "<unnamed>")')
      echo "        - $instance_id ($instance_name) - stopping..."
      
      if ! aws ec2 stop-instances --instance-ids "$instance_id" --no-cli-pager >/dev/null 2>&1; then
        echo "    Error: Failed to stop instance $instance_id"
        continue
      fi
    done < <(echo "$running_instances_json" | jq -c '.')
  else
    echo "      No running instances found"
  fi
}
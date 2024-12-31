#! /bin/bash

is_workday() {
    local workdays="$1"
    local current_day=$(date +%a)
    
    # Convert current day to our format
    case $current_day in
        Mon) current_day="M";;
        Tue) current_day="T";;
        Wed) current_day="W";;
        Thu) current_day="Th";;
        Fri) current_day="F";;
        Sat) current_day="Sa";;
        Sun) current_day="S";;
    esac
    
    [[ $workdays == *"$current_day"* ]]
    return $?
}

is_workhours() {
    local hours="$1"
    local start_time=$(echo $hours | cut -d'-' -f1)
    local end_time=$(echo $hours | cut -d'-' -f2)
    local current_time=$(date +%H%M)
    
    # Convert times to comparable integers
    start_time=${start_time//[^0-9]/}
    end_time=${end_time//[^0-9]/}
    
    [ $current_time -ge $start_time ] && [ $current_time -le $end_time ]
    return $?
}

should_shutdown_instances() {
    local account="$1"
    local is_disabled=$(echo "$account" | jq -r '.disabled // false')
    local workdays=$(echo "$account" | jq -r '.workdays // empty')
    local workhours=$(echo "$account" | jq -r '.workhours // empty')
    
    # If account is disabled, always shutdown
    if [ "$is_disabled" = "true" ]; then
        return 0
    fi
    
    # If both workdays and workhours are present
    if [ ! -z "$workdays" ] && [ ! -z "$workhours" ]; then
        if ! is_workday "$workdays" || ! is_workhours "$workhours"; then
            return 0
        fi
        return 1
    fi
    
    # If only workdays is present
    if [ ! -z "$workdays" ]; then
        if ! is_workday "$workdays"; then
            return 0
        fi
        return 1
    fi
    
    # If only workhours is present
    if [ ! -z "$workhours" ]; then
        if ! is_workhours "$workhours"; then
            return 0
        fi
        return 1
    fi
    
    return 1
}

main() {
  # Get current datetime in YYYYmmddHHmmss format
  NOW=$(date '+%Y%m%d%H%M%S')
  
  # Validate accounts.json exists
  if [ ! -f "accounts.json" ]; then
    echo "Error: accounts.json file not found"
    exit 1
  fi

  # Validate JSON format and array structure
  if ! jq empty accounts.json 2>/dev/null; then
    echo "Error: accounts.json is not valid JSON"
    exit 1
  fi

  if [ "$(jq 'type' accounts.json)" != '"array"' ]; then
    echo "Error: accounts.json must contain a JSON array"
    exit 1
  fi

  if [ "$(jq 'length' accounts.json)" -eq 0 ]; then
    echo "Error: accounts.json array is empty"
    exit 1
  fi

  # Define AWS regions
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
  
  # Read and process accounts.json
  while IFS= read -r account; do
    # Validate required fields
    account_id=$(echo "$account" | jq -r '.id')
    account_name=$(echo "$account" | jq -r '.name')
    access_key=$(echo "$account" | jq -r '.access')
    secret_key=$(echo "$account" | jq -r '.secret')
    
    # Check if any required fields are empty
    if [ -z "$account_id" ] || [ "$account_id" = "null" ] || \
       [ -z "$account_name" ] || [ "$account_name" = "null" ] || \
       [ -z "$access_key" ] || [ "$access_key" = "null" ] || \
       [ -z "$secret_key" ] || [ "$secret_key" = "null" ]; then
      echo "Skipping invalid account entry. Required fields missing:"
      echo "  ID: $account_id"
      echo "  Name: $account_name"
      echo "  Access Key: ${access_key:0:5}..."
      echo "  Secret Key: ${secret_key:0:5}..."
      echo "----------------------------------------"
      continue
    fi

    is_govcloud=$(echo "$account" | jq -r '.govcloud')
    
    echo "Account: $account_name ($account_id)"
    
    # Temporarily set AWS credentials for this account
    export AWS_ACCESS_KEY_ID=$access_key
    export AWS_SECRET_ACCESS_KEY=$secret_key
    export AWS_DEFAULT_OUTPUT=json
    
    # Determine which regions to use
    if [ "$is_govcloud" = "true" ]; then
      regions=("${AWS_REGIONS_GOVCLOUD[@]}")
      echo "  Using GovCloud regions"
    else
      regions=("${AWS_REGIONS[@]}")
      echo " Using commercial regions"
    fi
    
    # Loop through each region
    for region in "${regions[@]}"; do
      echo "  Checking region: $region"
      export AWS_DEFAULT_REGION=$region
      
      # Get instances for this region
      instances_json=$(aws ec2 describe-instances 2>/dev/null)
      if [ $? -ne 0 ]; then
        echo "  Error: Failed to get instances in $region"
        continue
      fi
      
      echo "  Successfully retrieved instances from $region"
      
      # Process instances with simpler jq command
      echo "  Processing instances:"
      instance_count=$(echo "$instances_json" | jq '.Reservations[].Instances | length' | awk '{sum += $1} END {print sum}')
      
      if [ -z "$instance_count" ] || [ "$instance_count" -eq 0 ]; then
        echo "    No instances found"
      else
        echo "$instances_json" | jq -r '.Reservations[].Instances[] | 
          "    - \(.InstanceId) (\(([.Tags[]? | select(.Key=="Name").Value] | first // "No Name"))) - \(.State.Name)"'
      fi
      
      # Check if instances should be shutdown
      if should_shutdown_instances "$account"; then
        echo "  Shutting down instances due to schedule/disabled status..."
        running_instances_json=$(echo "$instances_json" | jq -r '.Reservations[].Instances[] | select(.State.Name=="running")')
        if [ ! -z "$running_instances_json" ]; then
          echo "  Stopping instances:"
          while IFS= read -r instance; do
            instance_id=$(echo "$instance" | jq -r '.InstanceId')
            instance_name=$(echo "$instance" | jq -r '([.Tags[]? | select(.Key=="Name").Value] | first // "No Name")')
            echo "    - $instance_id ($instance_name)"
          done < <(echo "$running_instances_json" | jq -c '.')
          
          instance_ids=$(echo "$running_instances_json" | jq -r '.InstanceId')
          if ! aws ec2 stop-instances --instance-ids $instance_ids --no-cli-pager >/dev/null 2>&1; then
            echo "    Error: Failed to stop instances"
          fi
        else
          echo "    No running instances found"
        fi
      fi
    done
    echo "----------------------------------------"
  done < <(jq -c '.[]' accounts.json)
}

main $@

#!/bin/bash

# Load all .sh files from helpers directory
for helperFile in "$(dirname "${BASH_SOURCE[0]}")/helpers"/*.sh; do
  if [ -f "$helperFile" ]; then
    # shellcheck source=/dev/null
    . "$helperFile"
  fi
done

for utilFile in "$(dirname "${BASH_SOURCE[0]}")/utils"/*.sh; do
  if [ -f "$utilFile" ]; then
    # shellcheck source=/dev/null
    . "$utilFile"
  fi
done

for cmdFile in "$(dirname "${BASH_SOURCE[0]}")/commands"/*.sh; do
  if [ -f "$cmdFile" ]; then
    # shellcheck source=/dev/null
    . "$cmdFile"
  fi
done

main() {

  local accounts

  export TIMESTAMP=$(TZ='America/New_York' date '+%Y%m%d%H%M%S')
  # export INVENTORY_BASE="/Users/flackey/Source/fredlackey/public/aws-cleanup-docker/scrap/output"

  # Get accounts from config file
  if ! accounts=$(get_accounts); then
    echo "Unable to proceed: Failed to retrieve account information"
    exit 1
  fi

  # Verify we got valid JSON data
  if [[ -z "$accounts" ]]; then
    echo "Unable to proceed: No account data was returned"
    exit 1
  fi

  # Process each account - using jq directly on the accounts variable
  while IFS= read -r account; do

    # Display a message for each account
    echo "Processing account: $(jq -r '.name' <<< "$account") ($(jq -r '.id' <<< "$account"))"

    local isDisabled=$(is_disabled "$account")
    local isOutsideHours=$(is_outside_hours "$account")

    # Get the regions for the account
    regions=$(get_regions "$account")

    export ACCOUNT_ID=$(jq -r '.id' <<< "$account")
    export AWS_ACCESS_KEY_ID=$(jq -r '.access' <<< "$account")
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.secret' <<< "$account")

    # Loop through the regions.  For each region set the AWS_DEFAULT_REGION and run the cleanup command
    for region in $regions; do

      export AWS_DEFAULT_REGION=$region

      # If INVENTORY_BASE is set then populate INVENTORY_FOLDER
      if [ -n "$INVENTORY_BASE" ]; then
        export INVENTORY_FOLDER="${INVENTORY_BASE}/${ACCOUNT_ID}/${TIMESTAMP}/${region}"
      fi

      echo "  Region: $region"

      # If INVENTORY_FOLDER is set then save the inventory
      if [ -n "$INVENTORY_FOLDER" ]; then
        echo "    Saving inventory...";
        save_inventory
      else 
        echo "    Skipping inventory save...";
      fi

      if [ "$isDisabled" = "true" ] || [ "$isOutsideHours" = "true" ]; then
        shutdown_all_ec2
      else
        set_tracking_tags
      fi

    done
  
  done < <(jq -c '.[]' <<< "$accounts")
}

main "$@"

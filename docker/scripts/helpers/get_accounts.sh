#! /bin/bash

get_accounts() {

  # local config_file="/var/cleanup/config/accounts.json"
  local config_file="/Users/flackey/Source/fredlackey/public/aws-cleanup-docker/tests-accounts.json"

  local accounts

  # Check if file exists
  if [[ ! -f "$config_file" ]]; then
    echo "Error: Config file not found at $config_file" >&2
    return 1
  fi

  # Read JSON file into variable
  accounts=$(cat "$config_file")

  # Validate that it's an array
  if ! echo "$accounts" | jq -e 'type == "array"' >/dev/null; then
    echo "Error: Config file must contain a JSON array" >&2
    return 1
  fi

  # Validate each object has required properties
  if ! echo "$accounts" | jq -e 'all(.[]; has("id") and has("name") and has("access") and has("secret"))' >/dev/null; then
    echo "Error: Each account must have id, name, access, and secret properties" >&2
    return 1
  fi

  # If validation passes, output the accounts
  echo "$accounts"
  return 0
}

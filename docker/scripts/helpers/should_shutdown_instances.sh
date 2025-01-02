#! /bin/bash

should_shutdown_instances() {
    local accountJson="$1"
    local is_disabled=$(echo "$accountJson" | jq -r '.disabled // false')
    local workdays=$(echo "$accountJson" | jq -r '.workdays // empty')
    local workhours=$(echo "$accountJson" | jq -r '.workhours // empty')
    
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

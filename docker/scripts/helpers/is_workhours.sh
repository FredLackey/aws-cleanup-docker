#! /bin/bash

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

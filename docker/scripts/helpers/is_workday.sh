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

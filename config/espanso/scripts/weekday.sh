#!/bin/bash
set -m
# Get the current day of the week as a number (0 for Sunday, 1 for Monday, ..., 6 for Saturday)
current_day=$(date +%w)

target_day=$1
# Calculate the difference between weekday (1) and the current day
days_to_weekday=$((target_day - current_day))

#echo $days_to_weekday

fmt_str="+%d-%m-%Y"

# Add the difference to the current date to get weekday's date
if [ $days_to_weekday -ge 0 ]; then
  weekday_date=$(date -v"+$days_to_weekday"d "$fmt_str")
else
  weekday_date=$(date -v"$days_to_weekday"d "$fmt_str")
fi
# Print weekday's date
echo $weekday_date

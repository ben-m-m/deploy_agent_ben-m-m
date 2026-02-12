#!/usr/bin/bash
#
echo "Create parent directory attendance_tracker_{your name/version}."
read -p "Enter directory suffix?:" verdir
att_dir="attendance_tracker_$verdir"





mkdir -p $att_dir
touch $att_dir/attendance_checker.py
mkdir -p $att_dir/Helpers/
touch $att_dir/Helpers/assets.csv
touch $att_dir/Helpers/config.json
mkdir -p $att_dir/reports
touch $att_dir/reports/reports.log

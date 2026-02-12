#!/usr/bin/env bash
#
echo "Create parent directory attendance_tracker_{your name/version}."
read -p "Enter directory suffix?:" verdir
att_dir="attendance_tracker_$verdir"

clean_up() {
	echo "Interupted process, closing now:"
	tar -czvf "${att_dir}_archive.tar.gz" "$att_dir"
	rm -rf "${att_dir}_archive.tar.gz"
}

trap clean_up SIGINT

mkdir -p "$att_dir"
touch "$att_dir/attendance_checker.py"
mkdir -p "$att_dir/Helpers/"
touch "$att_dir/Helpers/assets.csv"
touch "$att_dir/Helpers/config.json"
mkdir -p "$att_dir/reports"
touch "$att_dir/reports/reports.log"

cat > "$att_dir/Helpers/config.json" <<EOF
{
  "warning": 75,
  "failure": 50
}
EOF


read -p "Do you want to update the attendance threshhold ? (y/n)" choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    read -p "Enter warning threshhold (default 75): " warning
    read -p "Enter failure threshhold (default 50): " failure

    sed -i "s/\"warning\": [0-9]\+/\"warning\": $warning/" "$att_dir/Helpers/config.json"
    sed -i "s/\"default\": [0-9]\+/\"default\": $failure/" "$att_dir/Helpers/config.json"
fi

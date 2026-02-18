#!/usr/bin/env bash
#
echo "Create parent directory attendance_tracker_{your name/version}."
read -p "Enter directory suffix?:" verdir
att_dir="attendance_tracker_$verdir"


#function for clean up followed by trap upon sigint
clean_up() {
	echo "Interupted process, closing now:"
	tar -czvf "${att_dir}_archive.tar.gz" "$att_dir"
	rm -rf "${att_dir}_archive.tar.gz"
}

trap clean_up SIGINT


#Check if directory exists and if not, creates directory
if [ -d "$att_dir" ]; then
	echo ""
	echo "Directory and files already exist"
	echo "----------------------------------"
else
	mkdir -p "$att_dir"
	touch "$att_dir/attendance_checker.py"
	mkdir -p "$att_dir/Helpers/"
	touch "$att_dir/Helpers/assets.csv"
	touch "$att_dir/Helpers/config.json"
	mkdir -p "$att_dir/reports"
	touch "$att_dir/reports/reports.log"
fi

#verify the json file exists and if not, creates it with default values
if [[ ! -s "$att_dir/Helpers/config.json" ]]; then
cat > "$att_dir/Helpers/config.json" <<EOF
{
  "warning": 75,
  "failure": 50
}
EOF
fi

 #warning=${warning:-75}
 #failure=${failure:-50}



#Prompts the user to change the attendance threshold

read -p "Do you want to update the attendance threshhold ? (y/n)" choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    read -p "Enter warning threshhold (default 75): " warning
    read -p "Enter failure threshhold (default 50): " failure

    #default value incase User clicks enter key
    warning=${warning:-75}
    failure=${failure:-50}

    #verify user input as numeric value
    
    if ! [[ "$warning" =~ ^[0-9]+$ ]] || ! [[ "$failure" =~ ^[0-9]+$ ]]; then
	    echo ""
	    echo "-------------------------------------"
	    echo "Thresholds must be numeric values !!!"
	    exit 1
    fi

    
	#check that the values are non negative but also less than 100

	if [[ "$warning" -le 0 || "$warning" -gt 100 || "$failure" -le 0 || "$failure" -gt 100 ]]; then
		echo ""
		echo "Thresholds must be between 1 and 100 !!!"
		exit 1
	fi

	#Correct entries where warning must be higher than failure
    
    if [[ "$warning" -le "$failure" ]]; then
	    echo ""
	    echo "Warning threshold must be higher than failure threshold !!!"
	    exit 1
    fi


    sed -i "s/\"warning\": [0-9]\+/\"warning\": $warning/" "$att_dir/Helpers/config.json"
    sed -i "s/\"failure\": [0-9]\+/\"failure\": $failure/" "$att_dir/Helpers/config.json"

    echo ""
    echo "-----------------------------------------"
    echo "Attendance Thresholds update Succesfully"
    echo "-----------------------------------------"
fi

# Validating the existence of python3 environment

if python3 --version >/dev/null 2>&1; then
	echo ""
	echo "Python3 is installed: $(python3 --version)"
else
	echo ""
	echo "Python3 is not available. Please install:"
fi

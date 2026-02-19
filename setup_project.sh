#!/usr/bin/env bash
#
set -e
echo "Create parent directory attendance_tracker_{your name/version}."
read -p "Enter directory suffix?:" verdir
att_dir="attendance_tracker_$verdir"


#function for clean up followed by trap upon sigint
clean_up() {
	echo "Interupted process, closing now:"
	tar -czvf "${att_dir}_archive.tar.gz" "$att_dir"
	rm -rf "${att_dir}"
	echo "Incomplete directory archived as ${att_dir}_archive.tar.gz and removed."
	exit 1
}

trap clean_up SIGINT


#Check if directory exists and if not, creates directory
if [ -d "$att_dir" ]; then
	echo ""
	echo "Directory and files already exist"
	echo "----------------------------------"
else
	mkdir -p "$att_dir" || { echo "Error: Failed: You do not have permission or invalid location"; exit 1;}
	touch "$att_dir/attendance_checker.py" || { echo "Error creating python file"; exit 1;}
	mkdir -p "$att_dir/Helpers/" || { echo "Error creating Helpers directory"; exit 1;}
	touch "$att_dir/Helpers/assets.csv" || { echo "Error creating assets.csv file"; exit 1;}
	touch "$att_dir/Helpers/config.json" || { echo "Error creating config.json file"; exit 1;}
	mkdir -p "$att_dir/reports" || { echo "Error creating reports directory"; exit 1;}
	touch "$att_dir/reports/reports.log" || { echo "Error creating reports.log file"; exit 1;}
fi

#verify the json file exists and if not, creates it with default values
if [[ ! -s "$att_dir/Helpers/config.json" ]]; then
cat > "$att_dir/Helpers/config.json" <<EOF
{
    "thresholds": {
        "warning": 95,
        "failure": 70
    },
    "run_mode": "live",
    "total_sessions": 15
}

EOF
fi
#populate the assets.csv file with sample data if it is empty or does not exist
if [[ ! -s "$att_dir/Helpers/assets.csv" ]]; then
cat > "$att_dir/Helpers/assets.csv" <<EOF
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
jose@example.com,Joseph Case,5,10
EOF
fi
#populate the attendance_checker.py file with the code if it is empty or does not exist
if [[ ! -s "$att_dir/attendance_checker.py" ]]; then
cat > "$att_dir/attendance_checker.py" <<EOF
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
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
    
    if ! [[ "$warning" =~ ^-?[0-9]+$ ]] || ! [[ "$failure" =~ ^-?[0-9]+$ ]]; then
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

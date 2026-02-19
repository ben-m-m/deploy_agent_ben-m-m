# deploy_agent_ben-m-m

# Overview

This project includes a Bash script that initializes an Attendance Tracking System Environment. The script generates the required directory structure, configuration files, place-holder/sample data and verifies system dependencies before executing the python file accompaning it inorder to send the right information to the right people.

The purpose of the script is to standardize project setup, enforce configuration validation and reduce errors caused by manual processes.Example: when the same environment is required in different servers.

# project structure

attendance_tracker_<suffix>/
│
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
├── reports/
    └── reports.log

# Functional Behavior
1. Prompt the user for a directory suffix
2. Creates project directory if it does not exist e.g attendance_tracker_<suffix>/
3. Initializes configuration files 
4. Adds sample CSV data for immediate testing
5. Allows the user to edit the threshold an validates their input. i.e numeric check, range (1-100), logical comparrison(warning > failure)
6. Updates the JSON file for later use via the python script (attendance_checker.py) automated emailing program
7. Verifies Python3 is installed so the use can run the python file

# How to run

- Upon downloading/clonig the repository
1. Make sure that setup_project.sh is executable.  
            chmod +x setup_project.sh
2. run the script. 
            ./setup_project.sh

# Interrupt Handling:

- Press Ctrl+C at any time during the script execution to trigger the trap.
- The ongoing process (directory created) will be archived as attendance_tracker_<suffix>_archive.tar.gz and the directory removed

# Threshold

-if no input is provide, defaults are used: warning = 75, Failure = 50.

# Environment validation

- The script checks if python3 is installed.  Success is printed if found; if not a warning to install before running the python file is sent.

# video run through.


# sample file of file structure and default content given as attendance_tracker_v1
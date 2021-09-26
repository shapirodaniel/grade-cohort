#!/bin/sh

#####################################################################################################
# This script allows you to clone an entire cohort's weekly checkpoint for grading
# 
# ----------------------------------------------------------------------------------
# NOTE: to run this script, execute the following shell command to grant permissions
# ----------------------------------------------------------------------------------
# $ chmod +x grade.sh
# 
# ------------------------------------------------------------------------------
# HOW TO USE: run this script in the directory that holds the week's assignments
# ------------------------------------------------------------------------------
# bash <path-to-this-script> <project|checkpoint-name> <path-to-student-records-csv>
# 
# --------
# EXAMPLE:
# --------
# bash ./grade.sh "Checkpoint.DOM" "/Users/myname/Documents/fullstack-academy/my-cohort/students.csv"
#####################################################################################################

# repo name as cli input param, ex "Checkpoint.DOM"
project_name=$1

# csv student list structured name,email,github
path_to_students_csv=$2

# create 'project-name-grades' directory if not already exists and set location
exists=$(mkdir "$project_name-grades")
cd "$project_name-grades"

# load csv and parse header
printf "reading $path_to_students_csv"
exec < $path_to_students_csv || exit 1
printf "parsing header"
read header
printf "structure of csv records: $header"

# loop all student records and parse name, email, github
while IFS="," 
do 
    # parse until we've run through all records
    read -r name email github
    [ -z "$name" ] && break

    # clone records and add "grade" branch, skipping any records that already exist
    if [ -d "$name" ]
    then
        printf "$name's project has already been cloned"
    else
        # clone project to project directory and create "grade" branch
        printf "cloning $github ($name)'s project and creating branch 'grade'"
        git clone git@github.com:$github/$project_name.git $name
        cd $name
        git checkout -b "grade"
        cd ..
    fi
done

exit 0
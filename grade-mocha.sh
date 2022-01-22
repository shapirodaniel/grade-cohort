#!/bin/sh

#######################################################################################################
# This script allows you to clone an entire cohort's weekly checkpoint for grading
# 
# -------------
# DEPENDENCIES: 
# -------------
# jq (https://stedolan.github.io/jq/download/)
# 
# ----------------------------------------------------------------------------------
# NOTE: to run this script, execute the following shell command to grant permissions
# ----------------------------------------------------------------------------------
# $ chmod +x grade.sh
# 
# ------------------------------------------------------------------------------
# HOW TO USE: run this script in the directory that holds the week's assignments
# ------------------------------------------------------------------------------
# $ bash <path-to-this-script> <project|checkpoint-name> <path-to-student-records-csv>
# 
# --------
# EXAMPLE:
# --------
# $ bash ./grade.sh "Checkpoint.DOM" "/Users/myname/Documents/fullstack-academy/my-cohort/students.csv"
#######################################################################################################

# repo name as cli input param, ex "Checkpoint.DOM"
project_name=$1

# csv student list structured name,email,github
path_to_students_csv=$2

# directory to store cloned repos and grades csv output
grades_dir="$project_name-grades"

# create 'project-name-grades' directory if not already exists and set location
if [ -d "$grades_dir" ] 
then 
    printf ">>>> $grades_dir already exists, skipping directory creation\n"
else    
    mkdir "$grades_dir"
fi

cd "./$grades_dir"

# write headers to grades csv
grades_csv="$project_name-grades.csv"
touch $grades_csv
grades_header="name,project_name,grade,submitted_at"
cat "./$grades_csv" | grep "$grades_header" || echo $grades_header >> $grades_csv

# load students csv and parse header
printf ">>>> reading $path_to_students_csv\n"
exec < $path_to_students_csv || exit 1
printf ">>>> parsing header\n"
read header
printf ">>>> structure of csv records: $header\n"

# loop all student records and parse name, email, github
while IFS="," 
do 
    # parse until we've run through all records
    read -r name email github
    [ -z "$name" ] && break

    # clone records and add "grade" branch, replacing any repos that already exist
    [ -d "$name" ] && rm -rf "$name"

    # clone project to project directory and create "grade" branch
    printf "cloning $github ($name)'s project and creating branch 'grade'"
    git clone git@github.com:$github/$project_name.git $name
    cd $name
    git checkout -b "grade"
    
    # get commit and timestamp
    sha=$(git rev-parse --verify HEAD)
    submitted_at=$(git show -s --format=%ct $sha)

    # copy mocha reporter instance into project directory and install deps
    cp ../../reporter.js ./reporter.js
    npm i

    # set test target, add mocha reporter and glob matcher for all *test*
    npm config set submitted_at $submitted_at
    npx npm-add-script -k "test:mocha" -v "mocha '{,!(node_modules)/**/}*test*.js' -R ./reporter.js"
    npm run test:mocha

    # calculate grade, timestamp of last commit
    grade=$(jq '.grade' grade.json | bc)
    submitted_at=$(jq '.submitted_at' grade.json)
    
    # write grade to file
    cat "../$grades_csv" | grep $github || echo "$name,$github,$project_name,$grade,$submitted_at" >> "../$grades_csv"

    cd ..
done

exit 0

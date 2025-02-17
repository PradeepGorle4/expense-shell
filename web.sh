#!/bin/bash

USERID=$(id -u)

# Assigning variables to color codes

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Storing the logs

LOGS_FOLDER="/var/log/expense.logs"
SCRIPT_NAME=$(echo $0 |cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M)
LOG_FILE_Name="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP"

check_root() {
    if [ $USERID -ne 0 ]
then
    echo -e " $R ERROR::.......You must have root user access to execute this script $N "
    exit 1
fi
}

validate() {
    if [ $? -ne 0 ]
    then
        echo "$1 .......FAILED"
        exit 1
    else
        echo "$1 .......SUCCESS"
    fi
}

check_root

mkdir -p $LOGS_FOLDER
validate "Creating logs folder"

echo "Script started executing at $TIMESTAMP" &>>$LOG_FILE_Name

dnf install nginx -y &>>$LOG_FILE_Name
validate "Installing nginx"

rm -rf /usr/share/nginx/html/*
validate "Removing existing html content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
validate "Downloading the default content"

cd /usr/share/nginx/html
validate "Moving to html folder"

unzip /tmp/frontend.zip &>>$LOG_FILE_Name

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE_Name
validate "Copying expense.conf"

systemctl enable nginx
validate "Enabling nginx"

systemctl restart nginx
validate "Retarting nginx"
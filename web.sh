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

echo "Script started executing at $TIMESTAMP" &>>$LOG_FILE_Name

dnf install nginx -y
validate "Installing nginx"

rm -rf /usr/share/nginx/html/*
validate "Removing default html content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
validate "Downloading the default content"

unzip /tmp/frontend.zip /usr/share/nginx/html

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf

systemctl enable nginx
validate "Enabling nginx"

systemctl restart nginx
validate "Retarting nginx"
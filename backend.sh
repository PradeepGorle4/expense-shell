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

dnf module disable nodejs -y &>>$LOG_FILE_Name
validate "Disabling default Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_Name
validate "Enabling Nodejs 20"

dnf install nodejs -y &>>$LOG_FILE_Name
validate "Installing nodejs"

id expense
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE_Name
    validate "Creating expense user"
else
    echo -e "Expense user is already exists...... $Y SKIPPING IT $N "

mkdir /app
validate "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_Name
validate "Downloading the backend application content"

cd /app
validate "moving to app directory"

unzip /tmp/backend.zip &>>$LOG_FILE_Name
validate "unzipping the backend application content in /app"

npm install &>>$LOG_FILE_Name
validate "Installing dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service


# Load the MYSQL schema to database server

dnf install mysql -y &>>$LOG_FILE_Name
validate "Installing mysql client"

mysql -h database.pradeepdevops.online -u root -pExpenseApp@1 < /app/schema/backend.sql
validate "Loading the transactions schema and tables to database server"

systemctl daemon-reload &>>$LOG_FILE_Name
validate "reloading daemon"

systemctl start backend &>>$LOG_FILE_Name
validate "starting backend service"

systemctl enable backend &>>$LOG_FILE_Name
validate "Enabling backend"

systemctl restart backend &>>$LOG_FILE_Name
validate "Restarting backend service"



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

echo "Script started executing at $TIMESTAMP" &>>$LOG_FILE_Name

dnf install mysql-server -y &>>$LOG_FILE_Name
validate "Installing mysql-server"

systemctl enable mysqld &>>$LOG_FILE_Name
validate "Enabling mysql-server"

systemctl start mysqld &>>$LOG_FILE_Name
validate "Starting mysql-server"

mysql -h database.pradeepdevops.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_Name

if [ $? -eq 0 ]
then
    echo -e "MYSQL root password already setup...... $Y SKIPPING $N "
else
    echo -e "Setting up mysql root password"
    mysql_secure_installation --set-root-pass ExpenseApp@1
    validate "setting Root password"
fi

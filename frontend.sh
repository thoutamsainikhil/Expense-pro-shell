#!/bin/bash

USER_ID=$(id -u)

RED="\e[31m"
GREEN="\e[32m"
Normal="\e[0m"

LOGS_FOLDER="/var/log/Expense-pro-shell-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}





echo "Script started executing at : $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT(){
if [ $USER_ID -ne 0 ]
then
  echo -e "$RED ERROR: You must be root user to run this script"
  exit 1
fi
}

echo "Script started executing at : $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing Nginx Web Server"

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "Enabling Nginx Service"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "Starting Nginx Service"    

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "Removing existing Nginx HTML files"    

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading frontend files"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
VALIDATE $? "Changing directory to Nginx HTML folder"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Extracting frontend files" 

systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "Restarting Nginx Service"


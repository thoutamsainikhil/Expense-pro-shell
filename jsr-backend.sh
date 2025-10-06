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

sudo dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling existing default nodeJS"

sudo dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enabling nodeJS 20"

sudo dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing nodeJS 20"

sudo dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing nodeJS 20"

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
useradd expense 
VALIDATE $? "Creating expense user"
else
echo "expense user already exists.. skipping" &>>$LOG_FILE_NAME
fi


mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "Creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading backend code"

cd /app &>>$LOG_FILE_NAME
VALIDATE $? "Changing directory to /app"

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Extracting backend code"


npm install &>>$LOG_FILE_NAME   
VALIDATE $? "Installing backend dependencies"

cp /home/ec2-user/expense-pro-shell/backend.service /etc/systemd/system/expense-backend.service


#prepare MySQL Schema

sudo dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing MySQL Client"

mysql -h mysql.jsrdaws.online -u root -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "Setting up the transaction schemas and tables

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Reloading systemd services"

systemctl enable expense-backend &>>$LOG_FILE_NAME
VALIDATE $? "Enabling expense-backend service"

systemctl start expense-backend &>>$LOG_FILE_NAME
VALIDATE $? "Starting expense-backend service"

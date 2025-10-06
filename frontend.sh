#!/bin/bash

USER_ID=$(id -u)
RED="\e[31m"
GREEN="\e[32m"
NORMAL="\e[0m"

LOGS_FOLDER="/var/log/Expense-pro-shell-logs"
LOG_FILE=$(basename "$0" | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "${RED}$2 ... FAILURE${NORMAL}"
    exit 1
  else
    echo -e "${GREEN}$2 ... SUCCESS${NORMAL}"
  fi
}

CHECK_ROOT() {
  if [ $USER_ID -ne 0 ]; then
    echo -e "${RED}ERROR: You must be root user to run this script${NORMAL}"
    exit 1
  fi
}

# Ensure script runs as root
CHECK_ROOT

mkdir -p $LOGS_FOLDER
echo "Script started executing at : $TIMESTAMP" &>>$LOG_FILE_NAME

# Install and configure Nginx
sudo dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing Nginx Web Server"

sudo systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "Enabling Nginx Service"

sudo systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "Starting Nginx Service"

sudo rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "Removing existing Nginx HTML files"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading frontend files"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
VALIDATE $? "Changing directory to Nginx HTML folder"

sudo unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Extracting frontend files"

sudo cp /home/ec2-user/Expense-pro-shell/expense.conf /etc/nginx/conf.d/expense.conf &>>$LOG_FILE_NAME
VALIDATE $? "Copying Nginx configuration file"

sudo nginx -t &>>$LOG_FILE_NAME
VALIDATE $? "Validating Nginx configuration"

sudo systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "Restarting Nginx Service"

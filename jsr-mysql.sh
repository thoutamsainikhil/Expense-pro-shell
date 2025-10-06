#!/bin/bash

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
      if [ $? -ne 0 ]
  then
    echo -e "$RED ERROR: Installation failed$Normal"
    exit 1
  else
  echo -e "$GREEN SUCCESS: Installation completed$Normal"
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



CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Enabling MySQL Service"    


systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Starting MySQL Service"

mysql -h mysql.jsrdaws.online -u root -pExpenseApp@1 -e "show databases;" &>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then
echo "MySQL Root password not setup" &>>$LOG_FILE_NAME
mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting MySQL root password"
else
echo "MySQL Root password already setup.. skipping"
fi
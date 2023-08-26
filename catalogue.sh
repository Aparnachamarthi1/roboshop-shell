#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
     echo -e "$R ERROR:: please run this script with root access $N"
     exit 1
 fi    

VALIDATE(){
    if [ $1 -ne 0 ];
then
    echo -e "$2 ... $R FAILURE $N"
    exit 1
else
    echo -e "$2 ...$G SUCCESS $N"
fi    
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

VALIDATE $? "setting up NPM Source"

yum install nodejs -y

VALIDATE $? "Installing nodeJS"

# once the user is created,if you run this script 2nd time
# this command will definetly fail
# IMPROVEMENT: first check the user already exist or not,if not exist then create

useradd roboshop &>>$LOGFILE

# write a condition to check directory already exist or not
mkdir /app &>>$LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "downloading the catalogue artifact"

cd /app &>>$LOGFILE 

VALIDATE $? "moving into app directory"

unzip /tmp/catalogue.zip &>>$LOGFILE

VALIDATE $? "unzipping catalogue"

npm install &>>$LOGFILE 

VALIDATE $? "installing dependencies"

#   give full path of catalogue.service because we are inside /app

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE

VALIDATE $? "copying catalogue.services"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "demon reload"

systemctl enable catalogue &>>$LOGFILE

VALIDATE $? "enabling catalogue"

systemctl start catalogue &>>$LOGFILE

VALIDATE $? "starting catalogue"

cp /home/centos/robotshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "copying mongo repo"

yum install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "installing mongo client"

mongo --host MONGODB-SERVER-IPADDRESS </app/schema/catalogue.js &>>$LOGFILE

VALIDATE $? "loading data into mongodb"






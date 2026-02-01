#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e0m"
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
MONGODB_HOST=mongodb.daws88s.space

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N"
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
         echo "$2 ...$R FAILURE $N"
         exit 1
    else
        echo "$2 ...$G SUCCESS $Y"
    fi         
}

dnf module disable nodejs -y &>>LOGS_FILE
VALIDATE $? "Disabling NODEJS Default version"

dnf module enable nodejs:20 -y &>>LOGS_FILE
VALIDATE $? "Enabling NODEJS 20"

dnf install nodejs -y &>>LOGS_FILE
VALIDATE $? "Install NODEJS"

id roboshop &>>LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? Downloading catalogue code

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/catalogue.zip
VALIDATE $? "Uzip catalogue code"

npm install
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "Starting and enabling catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y

mongosh --host $MONGODB_HOST </app/db/master-data.js
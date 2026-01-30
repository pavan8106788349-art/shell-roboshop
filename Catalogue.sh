#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e0m"

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

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating system user"

mkdir /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? Downloading catalogue code
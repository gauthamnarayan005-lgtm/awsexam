#!/bin/bash
# A simple deployment script for AWS (or any Linux machine)

echo "Starting Deployment..."

# Ensure we are in the correct directory (Assuming the repo was cloned to ~/awsexam)
cd ~/awsexam || exit

echo "Pulling latest code from GitHub..."
git pull origin main

echo "Installing Dependencies..."
npm install

echo "Restarting application using PM2..."
# Check if pm2 is installed, if not, print a message
if ! command -v pm2 &> /dev/null
then
    echo "pm2 could not be found, installing..."
    npm install -g pm2
fi

pm2 restart server || pm2 start server.js --name "student-app"

echo "Deployment finished."

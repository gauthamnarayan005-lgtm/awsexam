#!/bin/bash
# Deployment script tailored for Ubuntu EC2 instances

echo "Starting Deployment on Ubuntu EC2..."

# 1. Install Node.js if it is not installed
if ! command -v node &> /dev/null
then
    echo "Node.js is not installed. Installing Node.js via NodeSource..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# 2. Ensure we are in the correct directory (Assuming the repo is cloned in ~/awsexam)
cd ~/awsexam || exit

# 3. Pull latest code
echo "Pulling latest code from GitHub..."
git pull origin main

# 4. Install standard dependencies
echo "Installing Application Dependencies..."
npm install

# 5. Check and install PM2 globally if not present
echo "Restarting application using PM2..."
if ! command -v pm2 &> /dev/null
then
    echo "pm2 could not be found. Installing pm2 globally..."
    sudo npm install -g pm2
fi

# 6. Start or Restart the server
pm2 restart server || pm2 start server.js --name "student-app"

echo "Deployment finished successfully!"

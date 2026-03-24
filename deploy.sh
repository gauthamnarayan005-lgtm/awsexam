#!/bin/bash
# Deployment script tailored for Ubuntu EC2 instances with MySQL

echo "Starting Deployment on Ubuntu EC2..."

# 1. Install Node.js if it is not installed
if ! command -v node &> /dev/null
then
    echo "Node.js is not installed. Installing Node.js via NodeSource..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# 2. Install MySQL Server if it is not installed
if ! command -v mysql &> /dev/null
then
    echo "MySQL is not installed. Installing MySQL Server..."
    sudo apt-get update
    sudo apt-get install -y mysql-server
    sudo systemctl start mysql
    sudo systemctl enable mysql
fi

# 3. Ensure we are in the correct directory (Assuming the repo is cloned in ~/awsexam)
cd ~/awsexam || exit

# 4. Pull latest code
echo "Pulling latest code from GitHub..."
git pull origin main

# 5. Configure Database and Schema
echo "Configuring MySQL User and Schema..."
# Create the database strictly before granting privileges
sudo mysql -e "CREATE DATABASE IF NOT EXISTS studentdb;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'student_user'@'localhost' IDENTIFIED WITH mysql_native_password BY 'studentpass';"
sudo mysql -e "GRANT ALL PRIVILEGES ON studentdb.* TO 'student_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
# Load schema into database
sudo mysql < init.sql

# 6. Set up basic .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cat <<EOF > .env
PORT=80
DB_HOST=localhost
DB_USER=student_user
DB_PASSWORD=studentpass
DB_NAME=studentdb
EOF
fi

# 7. Install standard dependencies
echo "Installing Application Dependencies..."
npm install

# 8. Check and install PM2 globally if not present
echo "Restarting application using PM2..."
if ! command -v pm2 &> /dev/null
then
    echo "pm2 could not be found. Installing pm2 globally..."
    sudo npm install -g pm2
fi

# 9. Start or Restart the server
# Running as root (sudo pm2) so it can bind to port 80
sudo pm2 restart server || sudo pm2 start server.js --name "student-app"

echo "Deployment finished successfully! App will be running on port 80."

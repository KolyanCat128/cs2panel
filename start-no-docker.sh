#!/bin/bash
set -e

# --- Helper Functions ---
check_command() {
  if ! command -v $1 &> /dev/null; then
    echo "Error: $1 is not installed. Please install it and try again."
    exit 1
  fi
}

# --- Dependency Checks ---
echo "Checking for dependencies..."
check_command git
check_command java
check_command mvn
check_command go
check_command node
check_command npm
check_command psql
echo "All dependencies found."

# --- Clone or update the repository ---
if [ ! -d "cs2panel" ]; then
  echo "Cloning the cs2panel repository..."
  git clone https://github.com/KolyanCat128/cs2panel.git
fi

cd cs2panel
echo "Updating the project from GitHub..."
git pull origin main

# --- Database Setup (Manual Steps) ---
echo "--------------------------------------------------"
echo "MANUAL STEP: PostgreSQL Database Setup"
echo "--------------------------------------------------"
echo "Please ensure you have a PostgreSQL database named 'cs2panel' with a user 'cs2panel' and password 'cs2panel_dev_password'."
echo "You can create the database and user with the following commands:"
echo "  CREATE DATABASE cs2panel;"
echo "  CREATE USER cs2panel WITH PASSWORD 'cs2panel_dev_password';"
echo "  GRANT ALL PRIVILEGES ON DATABASE cs2panel TO cs2panel;"
echo "--------------------------------------------------"
read -p "Press [Enter] to continue once the database is set up..."

# --- Create a directory for PID files ---
mkdir -p .pids

# --- Start Hypervisor ---
echo "Starting Hypervisor..."
cd hypervisor
go build -o hypervisor.exe .
./hypervisor.exe &
echo $! > ../.pids/hypervisor.pid
cd ..
echo "Hypervisor started with PID $(cat .pids/hypervisor.pid)"

# --- Start Backend ---
echo "Starting Backend..."
cd backend
./mvnw spring-boot:run &
echo $! > ../.pids/backend.pid
cd ..
echo "Backend started with PID $(cat .pids/backend.pid)"

# --- Start Frontend ---
echo "Starting Frontend..."
cd frontend
npm install
npm start &
echo $! > ../.pids/frontend.pid
cd ..
echo "Frontend started with PID $(cat .pids/frontend.pid)"

echo "--------------------------------------------------"
echo "All services started successfully!"
echo "  - Hypervisor: http://localhost:8080"
echo "  - Backend:    http://localhost:8081"
echo "  - Frontend:   http://localhost:4200"
echo "--------------------------------------------------"
echo "Use stop-no-docker.sh to stop all services."
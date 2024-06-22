#!/bin/bash

# Function to start the container
start_container() {
  docker compose build
  if [ $? -eq 0 ]; then
    docker compose up -d
    echo "Docker container is running."
  else
    echo "Docker build failed. Container not started."
  fi
}

# Function to restart the container
restart_container() {
  docker compose restart
  echo "Docker container has been restarted."
}

# Function to stop the container
stop_container() {
  docker compose down
  echo "Docker container has been stopped."
}

# Function to create a new user in the container
create_user() {
  read -p "Enter the container name or ID: " container_name
  read -p "Enter new username: " username
  read -sp "Enter password for $username: " password
  echo
  docker exec -it $container_name bash -c "useradd -m $username && echo '$username:$password' | chpasswd"
  if [ $? -eq 0 ]; then
    echo "User $username has been created in the container."
  else
    echo "Failed to create user $username."
  fi
}

# Function to update the container
update_container() {
  container_name="jenkins-lab-updated"
  if [ -z "$container_name" ]; then
    echo "No running container found for the current Docker image."
    exit 1
  fi
  echo "Updating container $container_name"
  
  docker compose build
  if [ $? -eq 0 ]; then
    docker compose down
    docker compose up -d
    echo "Docker container has been updated and restarted."
  else
    echo "Docker build failed. Container not updated."
  fi
}

# Main menu
echo "Select an option:"
echo "1. Start container"
echo "2. Restart container"
echo "3. Stop container"
echo "4. Create a new user in the container"
echo "5. Update container with the latest Dockerfile changes"
read -p "Enter choice [1-5]: " choice

case $choice in
  1)
    start_container
    ;;
  2)
    restart_container
    ;;
  3)
    stop_container
    ;;
  4)
    create_user
    ;;
  5)
    update_container
    ;;
  *)
    echo "Invalid option selected."
    ;;
esac
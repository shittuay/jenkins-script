### README for Jenkins Installation

This guide provides instructions to install Jenkins using a Dockerfile, Docker Compose, and a script to set up the necessary environment. The installation process includes creating a Docker container for Jenkins, configuring it via Docker Compose, and running a setup script.

#### Prerequisites

- Docker installed on your system
- Docker Compose installed on your system

### Folder Contents

1. **Dockerfile**
2. **docker-compose.yml**
3. **install_jenkins.sh**

### Dockerfile

The Dockerfile defines the Jenkins container setup.

```Dockerfile
# Use the official Jenkins LTS image
FROM jenkins/jenkins:lts

# Switch to the root user
USER root

# Install Docker inside the Jenkins container
RUN curl -fsSL https://get.docker.com/ | sh

# Allow Jenkins user to use Docker without sudo
RUN usermod -aG docker jenkins

# Switch back to the Jenkins user
USER jenkins

# Expose the necessary ports
EXPOSE 8080
EXPOSE 50000

# Default Jenkins home directory
VOLUME /var/jenkins_home
```

### docker-compose.yml

The Docker Compose file sets up Jenkins with Docker in a containerized environment.

```yaml
version: '3'

services:
  jenkins:
    build: .
    container_name: jenkins
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    restart: always

volumes:
  jenkins_home:
```

### install_jenkins.sh

This script automates the setup process, including building the Docker image and starting the Jenkins container.

```bash
#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for Docker
if ! command_exists docker; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check for Docker Compose
if ! command_exists docker-compose; then
    echo "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Build the Docker image for Jenkins
echo "Building the Jenkins Docker image..."
docker-compose build

# Start the Jenkins container
echo "Starting the Jenkins container..."
docker-compose up -d

echo "Jenkins is being set up. Please wait a few moments for the initial setup to complete."

# Display initial admin password
echo "Fetching the initial admin password..."
sleep 30  # Wait for Jenkins to initialize
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

echo "Setup complete. Access Jenkins at http://localhost:8080"
```

### Installation Steps

1. **Clone the Repository**

   ```sh
   git clone <repository_url>
   cd <repository_folder>
   ```

2. **Make the Script Executable**

   ```sh
   chmod +x install_jenkins.sh
   ```

3. **Run the Installation Script**

   ```sh
   ./install_jenkins.sh
   ```

### Access Jenkins

- Open your browser and go to [http://localhost:8080](http://localhost:8080).
- Use the initial admin password displayed by the script to unlock Jenkins.

### Troubleshooting

- If you encounter issues with Docker or Docker Compose, ensure they are correctly installed and running.
- Check Docker logs for Jenkins container:

  ```sh
  docker logs jenkins
  ```

### Conclusion

This guide walks you through the installation of Jenkins using Docker and Docker Compose, with a script to streamline the setup process. By following these steps, you should have a fully functional Jenkins instance running in a Docker container.

#!/bin/bash

# If the docker group does not exist, create it.
if ! getent group docker; then
  groupadd -g 994 docker
fi

# Add the jenkins user to the docker group.
usermod -aG docker jenkins

# Change the ownership of the Docker socket
chown root:docker /var/run/docker.sock

# Check if the chown command was successful
if [ "$(stat -c '%G' /var/run/docker.sock)" != "docker" ]; then
  echo "Failed to change the ownership of the Docker socket"
  exit 1
fi

# Run the original Jenkins entrypoint script
exec tini -- /usr/local/bin/jenkins.sh
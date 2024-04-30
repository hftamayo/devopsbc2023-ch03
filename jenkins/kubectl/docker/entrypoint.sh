#!/bin/bash

# Change the ownership of the Docker socket
su -c "chown root:docker /var/run/docker.sock" root

# Run the original Jenkins entrypoint script
exec su -c "/sbin/tini -- /usr/local/bin/jenkins.sh" root
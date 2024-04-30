#!/bin/bash

# Change the ownership of the Docker socket
sudo chown root:docker /var/run/docker.sock

# Run the original Jenkins entrypoint script
exec sudo /sbin/tini -- /usr/local/bin/jenkins.sh
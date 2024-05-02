#!/bin/bash

# Change the ownership of the Docker socket
chown root:docker /var/run/docker.sock

# Run the original Jenkins entrypoint script
exec /sbin/tini -- /usr/local/bin/jenkins.sh
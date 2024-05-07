#!/bin/bash
if [ -S /var/run/docker.sock ]; then
    sudo chown root:docker /var/run/docker.sock
fi

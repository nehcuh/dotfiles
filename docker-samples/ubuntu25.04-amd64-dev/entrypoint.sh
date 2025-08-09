#!/bin/bash
set -e

# Configure SSH
sudo mkdir -p /var/run/sshd
sudo ssh-keygen -A 2>/dev/null || true

# Enable password authentication (can be disabled for key-only access)
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Allow root login (optional, for convenience)
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Start SSH service
sudo /usr/sbin/sshd -D &

# Keep the container running indefinitely
# Users can exec into it with: docker exec -it container_name zsh -l
# Or connect via SSH: ssh huchen@localhost -p 22 (password: 123456)
echo "Container started. SSH server running on port 22."
echo "SSH login: ssh huchen@localhost -p 22 (password: 123456)"
sleep infinity

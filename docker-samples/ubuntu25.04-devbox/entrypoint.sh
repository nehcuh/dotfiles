#!/bin/bash
set -e

# Optional SSH server - only start if ENABLE_SSH=true
if [[ "${ENABLE_SSH:-false}" == "true" ]]; then
    echo "Starting SSH server..."

    # Configure SSH
    sudo mkdir -p /var/run/sshd
    sudo ssh-keygen -A 2>/dev/null || true

    # Enable password authentication
    sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

    # Start SSH in background
    sudo /usr/sbin/sshd -D &

    echo "SSH server running on port 2222"
    echo "Login: ssh ${USERNAME}@localhost -p 2222"
fi

# Start interactive shell or keep container running
# Check if we have a TTY (interactive terminal)
if [ -t 0 ]; then
    # Interactive mode - start shell
    echo ""
    echo "Development environment ready. (Interactive mode)"
    echo "Projects directory: ~/Projects (mounted from host)"
    echo ""
    exec zsh -l
else
    # Non-interactive mode (docker-compose, background service)
    # Keep container running for exec access
    echo ""
    echo "Development environment ready. (Background mode)"
    echo "Projects directory: ~/Projects (mounted from host)"
    echo "Container is running. Use 'container exec devbox zsh' to enter."
    echo ""
    # Keep container alive
    exec tail -f /dev/null
fi

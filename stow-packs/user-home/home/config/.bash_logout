# Bash Logout Script
# This file is executed when bash exits

# Clear the screen for security
clear

# Save any pending history
history -a

# Optional: Clear history for security (uncomment if needed)
# history -c
# > ~/.bash_history

# Log logout time (optional)
echo "Logout at $(date)" >> ~/.shell_logout_log
#!/bin/bash
set -euo pipefail

set_defaults() {
  export DEFAULT_USER="${CONTAINER_USER:-container}" 
  export DEFAULT_USER_ID="${CONTAINER_USER_ID:-1001}"
  export DEFAULT_GROUP_ID="${CONTAINER_GRP_ID:-1001}"
  export HOME_DIR="/home/$DEFAULT_USER"
  export APP_DIR="/node/app"
  export HOME="$HOME_DIR"
}

create_or_update_user_and_group() {
    # Check if the group exists, if not, create it with the specified GID
    getent group "$DEFAULT_USER" >/dev/null 2>&1 || groupadd -g "$DEFAULT_GROUP_ID" "$DEFAULT_USER"

    # Check if the user exists, if not, create it with the specified UID and GID
    id -u "$DEFAULT_USER" >/dev/null 2>&1 || useradd --shell /bin/bash -u "$DEFAULT_USER_ID" -g "$DEFAULT_GROUP_ID" -o -c "" -m "$DEFAULT_USER"

    # Print the UID and GID of the user
    echo "Starting with UID/GID: $(id -u "$DEFAULT_USER")/$(getent group "$DEFAULT_USER" | cut -d ":" -f 3)"
}

set_defaults

create_or_update_user_and_group

# Create directories if they don't exist
mkdir -p "$HOME_DIR" "$APP_DIR"

# Set ownership for directories
chown -R "$DEFAULT_USER_ID:$DEFAULT_GROUP_ID" "$HOME_DIR" "$APP_DIR"

# Execute the command with the specified user using 'gosu'
exec /usr/local/bin/gosu "$DEFAULT_USER" "$@"

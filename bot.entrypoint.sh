#!/bin/bash

# Display system information
uname -srmo
date

# Move default scripts if directory exists
if [ -d "default_scripts" ]; then
  mv default_scripts/* scripts
  rm -r default_scripts
  echo "Copied default scripts"
fi

# Copy config file if not present
if [ ! -f "data/config.ini" ]; then
  cp config.ini.configured data/config.ini
fi

# Create symbolic link for config file
ln -fs data/config.ini config.ini

# Define variables for SinusBot and yt-dlp
SINUSBOT="./sinusbot"
YTDL="yt-dlp"

# Update yt-dlp
echo "Updating yt-dlp..."
$YTDL --restrict-filename -U
$YTDL --version

# Initialize PID
PID=0

# Define handler for graceful shutdown
kill_handler() {
  echo "Shutting down..."
  kill -s SIGINT -$(ps -o pgid= $PID | grep -o '[0-9]*')
  while [ -e /proc/$PID ]; do
    sleep .5
  done
  exit 0
}

# Set trap for signals
trap 'kill ${!}; kill_handler' SIGTERM # docker stop
trap 'kill ${!}; kill_handler' SIGINT  # CTRL + C

# Drop privileges if UID or GID are set
if [[ -v UID ]] || [[ -v GID ]]; then
  cap_prefix="-cap_"
  caps="$cap_prefix$(seq -s ",$cap_prefix" 0 $(cat /proc/sys/kernel/cap_last_cap))"
  SETPRIV="setpriv --clear-groups --inh-caps=$caps"

  # Set user id
  if [[ -v UID ]]; then
    echo "User ID: $UID"
    SETPRIV="$SETPRIV --reuid=$UID"
    echo "Change file owner..."
    chown -R "$UID" "$PWD"
  fi

  # Set group id
  if [[ -v GID ]]; then
    echo "Group ID: $GID"
    SETPRIV="$SETPRIV --regid=$GID"
    echo "Change file group..."
    chown -R ":$GID" "$PWD"
  fi

  echo "Drop privileges..."
  SINUSBOT="$SETPRIV $SINUSBOT"
  YTDL="$SETPRIV $YTDL"
fi

# Clear yt-dlp cache
echo "Clearing yt-dlp cache..."
$YTDL --rm-cache-dir

# Start SinusBot with optional password override
echo "Starting SinusBot..."
if [[ -v OVERRIDE_PASSWORD ]]; then
  echo "Overriding password..."
  $SINUSBOT --override-password="${OVERRIDE_PASSWORD}" &
else
  $SINUSBOT &
fi

# Capture the PID of the SinusBot process
PID=$!
echo "PID: $PID"

# Keep the script running
while true; do
  tail -f /dev/null &
  wait ${!}
done

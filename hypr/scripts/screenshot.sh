#!/usr/bin/env bash

# Check if wf-recorder is already running and stop it
wf-recorder_check() {
  if pgrep -x "wf-recorder" >/dev/null; then
    pkill -INT -x wf-recorder
    notify-send "Recording Stopped" "$(cat /tmp/recording.txt)"
    wl-copy <"$(cat /tmp/recording.txt)"
    exit 0
  fi
}

wf-recorder_check

# Create directories if they don't exist
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/Videos/ScreenRecordings

# Fuzzel selection menu
SELECTION=$(echo -e "Screenshot Selection\nRecord Selection" | fuzzel -d -p "󰄀 " -w 25 -l 2)

# Generate file paths with timestamp
IMG="${HOME}/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
VID="${HOME}/Videos/ScreenRecordings/$(date +%Y-%m-%d_%H-%M-%S).mp4"

case "$SELECTION" in
"Screenshot Selection")
  grim -g "$(slurp)" "$IMG"
  wl-copy <"$IMG"
  notify-send "Screenshot Taken" "$IMG"
  ;;
"Record Selection")
  echo "$VID" >/tmp/recording.txt
  notify-send "Recording Started" "Select area to record. Press mainMod+PRINT again to stop."
  wf-recorder -a -g "$(slurp)" -f "$VID" &>/dev/null &
  ;;
*) ;;
esac

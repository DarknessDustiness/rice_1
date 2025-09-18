#!/usr/bin/env bash

# This script sets a random wallpaper, generates a color palette
# using pywal, and applies it to waybar.

# --- Configuration ---
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers/"

# --- Script Logic ---

# Check if a specific wallpaper path is provided as an argument.
# If an argument ($1) is present and the file exists, use it.
if [ -n "$1" ] && [ -f "$1" ]; then
    RANDOM_WALLPAPER="$1"
else
    # If no argument or the file doesn't exist, use the original logic.
    if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR")" ]; then
        echo "Error: The wallpaper directory '$WALLPAPER_DIR' does not exist or is empty." >&2
        exit 1
    fi
    RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f -regex ".*\.\(jpg\|jpeg\|png\|gif\|bmp\)" | shuf -n 1)
fi

swww img "$RANDOM_WALLPAPER" -t random --transition-fps 60 || {
    echo "Error: 'swww img' command failed. Check if swww is installed and the daemon is running." >&2
    exit 1
}

# Generate a color palette with pywal from the new wallpaper.
# The "-t" flag tells pywal to use our custom template for Hyprland.
wal -i "$RANDOM_WALLPAPER" -n -t || {
    echo "Warning: 'wal' command failed. Color palette may not be updated." >&2
}

pkill -SIGUSR2 waybar || {
    echo "Warning: 'waybar' was not running. Starting a new instance." >&2
}
waybar &

# Reload Hyprland to apply the new color scheme from the generated file.
hyprctl reload

#!/bin/bash
ENGINE=$1
WALLPAPER=$(awww query | awk -F': ' '{print $NF}' | head -1)
$ENGINE "$WALLPAPER"

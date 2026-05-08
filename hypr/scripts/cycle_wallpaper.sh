#!/bin/bash

while true; do
  awww img $(find ~/Pictures/wallpapers -type f | shuf -n 1)
  sleep 300
done
#!/usr/bin/env bash

if [ -z "${ACCESS_TOKEN}" ] || [ -z "${DESTINATION_DIR}" ]; then
  echo "ERROR: Environment variables were not set!"
  exit 1
fi

LOG_DIR="/var/www/html/bezanka"

# Download list of latest Instagram photos
curl --silent "https://api.instagram.com/v1/users/self/media/recent?access_token=${ACCESS_TOKEN}&count=6" \
    | jq '.' \
    | grep -A4 "standard_resolution" \
    | grep "jpg" \
    | cut -d '"' -f4 \
    > "${LOG_DIR}/instagram_last_pics.txt"

# Check if there are new photos
#   If yes, download them and move list to backup file
id=1
if [ ! -f "${LOG_DIR}/instagram_last_pics.txt" ] || ! diff "${LOG_DIR}/instagram_last_pics.txt" "${LOG_DIR}/instagram_last_pics.bck.txt" || [ ! -f "${DESTINATION_DIR}/instagram-photo-6.jpg" ]; then
  while read -r link; do
    wget "${link}" -O "${DESTINATION_DIR}/instagram-photo-${id}.jpg"
    ((++id))
  done < "${LOG_DIR}/instagram_last_pics.txt"
  mv "${LOG_DIR}/instagram_last_pics.txt" "${LOG_DIR}/instagram_last_pics.bck.txt"
fi

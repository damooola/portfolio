#!/bin/sh
# Screenshots my personal Medium posts as phone-sized images for the
# Writing section's "Off the clock" row. Needs Microsoft Edge (or point
# BROWSER at Chrome). Re-run if a post changes:
#   sh tool/shoot_medium.sh
BROWSER="${BROWSER:-/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe}"
UA="Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
# Absolute Windows path: Edge and Windows Python both need to see it.
TMP="$(pwd -W)/build/medium-shots"
mkdir -p "$TMP"

shoot() {
  "$BROWSER" --headless=new --disable-gpu --hide-scrollbars --user-data-dir="$TMP/profile" \
    --window-size=500,1000 --virtual-time-budget=15000 --user-agent="$UA" \
    --screenshot="$TMP/$1.png" "$2" >/dev/null 2>&1
  python -c "from PIL import Image; Image.open('$TMP/$1.png').convert('RGB').save('assets/writing/$1.jpg', quality=82, optimize=True)"
  echo "assets/writing/$1.jpg"
}

shoot better-place 'https://medium.com/wake-write-win/making-the-world-a-better-place-025bda69cc1f'
shoot what-others-think 'https://medium.com/new-writers-welcome/do-not-care-about-what-others-think-db9cc3a21b6c'
shoot happiness 'https://medium.com/wake-write-win/is-true-happiness-an-illusion-0a64490a9e9f'
rm -rf "$TMP"

#!/bin/bash
source <(gpg -d t1.env.gpg)
read -p "Enter a key title: " KEY_TITLE
KEY_PATH=${1:-"$HOME/.ssh/id_ed25519.pub"}
PUB_KEY=$(cat "$KEY_PATH")

echo "Uploading SSH key to GitHub..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -u "$GITHUB_USERNAME:$GITHUB_TOKEN" \
  -X POST https://api.github.com/user/keys \
  -H "Accept: application/vnd.github+json" \
  -d "{\"title\":\"$KEY_TITLE\",\"key\":\"$PUB_KEY\"}")

if [ "$RESPONSE" == "201" ]; then
    echo "SSH key successfully added to GitHub!"
else
    echo "Failed to add SSH key. HTTP Status: $RESPONSE"
fi

echo
read -p "Press Enter to test SSH connection to GitHub..."
ssh -T git@github.com

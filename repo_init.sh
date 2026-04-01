##!/bin/bash
#source <(gpg -d t1.env.gpg)
#read -p "Enter a key title: " KEY_TITLE
#KEY_PATH=${1:-"$HOME/.ssh/id_ed25519.pub"}
#PUB_KEY=$(cat "$KEY_PATH")
#
#echo $GITHUB_USERNAME
#echo $GITHUB_TOKEN
#
#echo "Uploading SSH key to GitHub..."
#
#RESPONSE=$(curl -L \
#  -X POST \
#  -H "Accept: application/vnd.github+json" \
#  -H "Authorization: Bearer $GITHUB_TOKEN" \
#  -H "X-GitHub-Api-Version: 2026-03-10" \
#  https://api.github.com/user/keys \
#  -d "{\"title\":\"$KEY_TITLE\",\"key\":\"$PUB_KEY\"}")
#
##RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
##  -u "$GITHUB_USERNAME:$GITHUB_TOKEN" \
##  -X POST https://api.github.com/user/keys \
##  -H "Accept: application/vnd.github+json" \
##  -d "{\"title\":\"$KEY_TITLE\",\"key\":\"$PUB_KEY\"}")
#
#echo $RESPONSE
#
#if [ "$RESPONSE" == "201" ]; then
#    echo "SSH key successfully added to GitHub!"
#else
#    echo "Failed to add SSH key. HTTP Status: $RESPONSE"
#fi
#
#echo
#read -p "Press Enter to test SSH connection to GitHub..."
#ssh -T git@github.com


#!/bin/bash

# Charger les variables depuis le fichier chiffré
source <(gpg -d t1.env.gpg)

# Demander le titre de la clé
read -p "Enter a key title: " KEY_TITLE

# Chemin de la clé publique (prend l'argument ou la valeur par défaut)
KEY_PATH=${1:-"$HOME/.ssh/id_ed25519.pub"}

if [ ! -f "$KEY_PATH" ]; then
  echo "Erreur: Fichier clé non trouvé : $KEY_PATH"
  exit 1
fi

PUB_KEY=$(cat "$KEY_PATH")

echo "Username : $GITHUB_USERNAME"
echo "Uploading SSH key '$KEY_TITLE' to GitHub..."

# === Requête avec capture du code HTTP et du body ===
RESPONSE=$(curl -L -s -w "\n%{http_code}" \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2026-03-10" \
  https://api.github.com/user/keys \
  -d "{\"title\":\"$KEY_TITLE\",\"key\":\"$PUB_KEY\"}")

# Séparer le body et le code HTTP
HTTP_BODY=$(echo "$RESPONSE" | head -n -1)
HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)

echo "HTTP Status: $HTTP_CODE"

if [ "$HTTP_CODE" = "201" ]; then
  echo "✅ SSH key successfully added to GitHub!"
  echo "Title: $KEY_TITLE"
  echo "Key ID: $(echo "$HTTP_BODY" | grep -o '"id":[^,}]*' | cut -d: -f2)"
else
  echo "❌ Failed to add SSH key."
  echo "HTTP Status: $HTTP_CODE"
  echo "Response: $HTTP_BODY"
  exit 1
fi

echo
read -p "Press Enter to test SSH connection to GitHub..."
ssh -T git@github.com

#!/bin/bash
# deploy-lfs.sh

# Config check
if [ ! -f "config.env" ]; then
    cp config.env.template config.env
fi

echo "Please edit config.env with your credentials before continuing."
echo "Options:"
echo "1. Edit now using nano"
echo "2. I've already edited config.env"
echo "3. Exit to edit manually"
read -p "Choose option (1-3): " choice

case $choice in
    1)
        nano config.env
        read -p "Have you completed editing config.env? (y/n): " confirm
        if [ "$confirm" != "y" ]; then
            echo "Please edit config.env and run the script again"
            exit 1
        fi
        ;;
    2)
        echo "Using existing config.env"
        ;;
    3)
        echo "Edit config.env and run script again when ready"
        exit 0
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

source config.env

# Validate config
if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_EMAIL" ]; then
    echo "Error: Required values missing in config.env"
    exit 1
fi

# Setup directories
mkdir -p $LFS_BASE_DIR/{repos,scripts,logs}
chmod -R 755 $LFS_BASE_DIR

# Install dependencies
apt-get update
apt-get install -y git git-lfs curl jq

# Configure git
git config --global user.name "$GITHUB_USERNAME"
git config --global user.email "$GITHUB_EMAIL"
git config --global credential.helper store
echo "https://$GITHUB_TOKEN:x-oauth-basic@github.com" > ~/.git-credentials

# Install Git LFS
git lfs install --skip-repo

# Setup monitoring
cp scripts/monitor.sh $LFS_BASE_DIR/scripts/
chmod +x $LFS_BASE_DIR/scripts/monitor.sh
(crontab -l 2>/dev/null; echo "0 * * * * $LFS_BASE_DIR/scripts/monitor.sh") | crontab -

# Run initial sync
chmod +x scripts/sync-repos.sh
./scripts/sync-repos.sh

# Setup GitHub Action
chmod +x scripts/setup-action.sh
./scripts/setup-action.sh

echo "LFS deployment complete. Repositories synced and LFS enabled."

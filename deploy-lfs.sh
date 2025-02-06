#!/bin/bash
# deploy-lfs.sh

# Load configuration
if [ ! -f "config.env" ]; then
    echo "Error: config.env not found. Copy config.env.template to config.env and update values."
    exit 1
fi
source config.env

# Check required values
if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_EMAIL" ]; then
    echo "Error: Required GitHub configuration missing in config.env"
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

# Install and configure Git LFS
git lfs install --skip-repo
git config --global lfs.contenttype false

# Copy monitoring script
cp scripts/monitor.sh $LFS_BASE_DIR/scripts/
chmod +x $LFS_BASE_DIR/scripts/monitor.sh

# Setup monitoring cron
(crontab -l 2>/dev/null; echo "0 * * * * $LFS_BASE_DIR/scripts/monitor.sh") | crontab -

# Setup GitHub Action
bash scripts/setup-action.sh

echo "LFS deployment complete. New repositories will automatically use LFS for files >$LFS_SIZE_LIMIT"

#!/bin/bash
# deploy-lfs.sh

# Load configuration
if [ ! -f "config.env" ]; then
    echo "Error: config.env not found"
    exit 1
fi
source config.env

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

echo "LFS deployment complete. Existing repositories synced and new repositories will use LFS for files >$LFS_SIZE_LIMIT"

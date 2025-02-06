#!/bin/bash
# deploy-lfs.sh

# Config check and menu
if [ ! -f "config.env" ]; then
    cp config.env.template config.env
fi

echo "Options: 1.Edit now (nano) 2.Use existing config 3.Exit"
read -p "Choose (1-3): " choice

case $choice in
    1) nano config.env
       read -p "Config complete? (y/n): " confirm
       [[ "$confirm" != "y" ]] && exit 1;;
    2) echo "Using existing config";;
    3) exit 0;;
    *) exit 1;;
esac

source config.env

# Setup server
mkdir -p $LFS_BASE_DIR/{repos,objects,locks}
chmod -R 755 $LFS_BASE_DIR

# Install and configure
apt-get update && apt-get install -y git git-lfs nginx curl jq
git config --global user.name "$GITHUB_USERNAME"
git config --global user.email "$GITHUB_EMAIL"

# Configure Nginx for LFS
cat > /etc/nginx/sites-available/git-lfs << EOF
server {
    listen 80;
    server_name $LFS_SERVER_NAME;
    
    location /objects {
        root $LFS_BASE_DIR;
        autoindex off;
    }
    
    location /locks {
        root $LFS_BASE_DIR;
        autoindex off;
    }
}
EOF

ln -sf /etc/nginx/sites-available/git-lfs /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx

# Configure Git LFS
git config --global lfs.url "http://$LFS_SERVER_NAME/objects"
git lfs install --skip-smudge

# Run initial sync
./scripts/sync-repos.sh

echo "LFS server deployed at http://$LFS_SERVER_NAME"

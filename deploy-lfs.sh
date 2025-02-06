#!/bin/bash
# deploy-lfs.sh

# Check config.env
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

# Rest of your deployment script here
source config.env

# Validate required values
if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_EMAIL" ]; then
    echo "Error: Required values missing in config.env"
    exit 1
fi

# Continue with installation...

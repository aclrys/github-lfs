#!/bin/bash
# sync-repos.sh

source /root/github-lfs/config.env

# Get list of repositories
get_repos() {
    curl -H "Authorization: token $GITHUB_TOKEN" \
         "https://api.github.com/users/$GITHUB_USERNAME/repos?per_page=100" | \
    jq -r '.[].name'
}

# Sync repository
sync_repo() {
    local repo=$1
    local repo_dir="$LFS_BASE_DIR/repos/$repo"
    
    mkdir -p "$repo_dir"
    cd "$repo_dir"
    
    if [ ! -d ".git" ]; then
        git clone "https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$repo.git" .
    fi
    
    git lfs install
    echo "* filter=lfs diff=lfs merge=lfs -text size=5MB" > .gitattributes
    git add .gitattributes
    git commit -m "Initialize LFS" || true
    git push || true
}

# Main sync process
main() {
    for repo in $(get_repos); do
        echo "Syncing $repo..."
        sync_repo "$repo"
    done
}

main

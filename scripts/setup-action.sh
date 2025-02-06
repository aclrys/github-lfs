#!/bin/bash
# scripts/setup-action.sh

source ../config.env

# Create GitHub Action workflow via API
workflow_content=$(cat << 'EOF'
name: LFS Management
on:
  repository:
    types: [created]
  workflow_dispatch:

jobs:
  setup-lfs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Configure LFS
        env:
          GH_TOKEN: ${{ secrets.GH_TOKEN }}
        run: |
          git lfs install
          echo "* filter=lfs diff=lfs merge=lfs -text size=5MB" > .gitattributes
          git add .gitattributes
          git commit -m "Initialize LFS"
          git push
EOF
)

# Convert to base64 for API
workflow_base64=$(echo "$workflow_content" | base64)

# Create workflow via GitHub API
curl -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$GITHUB_USERNAME/.github/contents/workflow-templates/lfs-setup.yml" \
  -d "{\"message\":\"Add LFS workflow template\",\"content\":\"$workflow_base64\"}"

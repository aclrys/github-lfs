# GitHub LFS Automation

Automatically configures Git LFS for all repositories in your GitHub account.

## Step-by-Step Deployment

1. **Generate GitHub Token**
   - Go to github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Select scopes:
     - [x] repo (Full control)
     - [x] workflow
     - [x] admin:org
     - [x] delete_repo
   - Copy the generated token

2. **Server Setup**
```bash
cd /root
git clone https://github.com/aclrys/github-lfs.git
cd github-lfs
```

3. **Configure Settings**
```bash
cp config.env.template config.env
nano config.env  # Add your details:
```
Required config.env values:
```bash
GITHUB_TOKEN="your_token"
GITHUB_USERNAME="your_username"
GITHUB_EMAIL="your@email.com"
LFS_BASE_DIR="/root/github-lfs"
ALERT_EMAIL="your@email.com"
```

4. **Deploy**
```bash
chmod +x deploy-lfs.sh
./deploy-lfs.sh
```

## Features
- Auto-configures LFS for new repositories
- Moves files >5MB to LFS storage
- Monitors storage usage
- Email alerts for storage threshold

## Maintenance
- Logs: /root/github-lfs/logs/
- Monitor script: /root/github-lfs/scripts/monitor.sh
- Storage alerts: Configured email

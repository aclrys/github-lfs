# GitHub LFS Automation

Automatically configures Git LFS for all repositories in your GitHub account.

## Setup

1. Generate GitHub token at github.com/settings/tokens with permissions:
   - repo (full)
   - workflow
   - admin:org
   - delete_repo

2. Configure settings:
```bash
cp config.env.template config.env
nano config.env  # Edit with your details
```

3. Deploy:
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

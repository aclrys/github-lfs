
#!/bin/bash
# scripts/monitor.sh

source /root/github-lfs/config.env

# Check storage usage
usage=$(df -h $LFS_BASE_DIR | awk 'NR==2 {print $5}' | tr -d '%')
if [ $usage -gt $STORAGE_THRESHOLD ]; then
    echo "WARNING: LFS storage at ${usage}%" | mail -s "LFS Storage Alert" $ALERT_EMAIL
fi

# Log LFS operations
find $LFS_BASE_DIR/logs -name "*.log" -mtime +7 -delete
date >> $LFS_BASE_DIR/logs/lfs.log
git lfs status >> $LFS_BASE_DIR/logs/lfs.log

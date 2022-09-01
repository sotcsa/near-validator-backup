#!/bin/bash

DATE=$(date +%Y-%m-%d-%H-%M)
DATADIR=~/.near/data
BACKUP_BASEDIR=~/.near/backup
BACKUPDIR=${BACKUP_BASEDIR}/near_${DATE}

mkdir -p $BACKUPDIR

sudo systemctl stop neard.service

wait

echo "NEAR node was stopped" | ts

if [ -d "$BACKUPDIR" ]; then
  echo "Backup started" | ts
  cp -rf $DATADIR/ ${BACKUPDIR}/

  # Submit backup completion status
  curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/4684caec-fb1f-4dd8-be5f-51934460ea73
  # Slack WebHook in Tibimez#near channel
  curl -s -o /dev/null -X POST --data-urlencode "payload={\"channel\": \"#near\", \"username\": \"backup-bot\", \"text\": \"sotcsa-backup: created new backup\", \"icon_emoji\": \":ghost:\"}" $SLACK_WEBHOOK

  echo "Backup completed" | ts
else
  echo $BACKUPDIR is not created. Check your permissions.
  exit 0
fi

sudo systemctl start neard.service

echo "NEAR node was started" | ts

echo "Delete old backups, keeping 2 latest backups only"
ls -td -1 "${BACKUP_BASEDIR}/"* | tail -n +3 | xargs -I {} rm -rf {}


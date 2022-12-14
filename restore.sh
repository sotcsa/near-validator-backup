#!/bin/bash

DATADIR=~/.near/data
BACKUPDIR=~/.near/backup
LATEST_BACKUP=$(ls -td $BACKUPDIR/* | head -1)


echo "NEAR node was stopped" | ts

if [ -d "$LATEST_BACKUP" ]; then
  rm -rf /tmp/data/
  sudo systemctl stop neard.service
  wait
  
  echo "Restore from backup started" | ts
  
  mv $DATADIR /tmp/
  mv $LATEST_BACKUP/data/ $DATADIR

  # Submit backup completion status, you can use healthchecks.io, betteruptime.com or other services
  #curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/4684caec-fb1f-4dd8-be5f-51934460ea73
  
  # Slack WebHook in Tibimez#near channel
  curl -s -o /dev/null -X POST --data-urlencode "payload={\"channel\": \"#near\", \"username\": \"restore-bot\", \"text\": \"sotcsa-backup: restored from backup\", \"icon_emoji\": \":warning:\"}" $SLACK_WEBHOOK
  
  echo "Restore from backup completed" | ts
  
  sudo systemctl start neard.service
else
  echo No backup yet | ts
  exit 0
fi


echo "NEAR node was started" | ts


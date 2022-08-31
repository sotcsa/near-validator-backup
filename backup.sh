#!/bin/bash

DATE=$(date +%Y-%m-%d-%H-%M)
DATADIR=~/.near/data
BACKUPDIR=~/.near/backup/near_${DATE}

mkdir -p $BACKUPDIR

sudo systemctl stop neard.service

wait

echo "NEAR node was stopped" | ts

if [ -d "$BACKUPDIR" ]; then
  echo "Backup started" | ts
  cp -rf $DATADIR/ ${BACKUPDIR}/

  # Submit backup completion status, you can use healthchecks.io, betteruptime.com or other services
  curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/4684caec-fb1f-4dd8-be5f-51934460ea73
  echo "Backup completed" | ts
else
  echo $BACKUPDIR is not created. Check your permissions.
  exit 0
fi

sudo systemctl start neard.service

echo "NEAR node was started" | ts


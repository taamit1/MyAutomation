/usr/bin/rsync -avvP --rsh=ssh --partial --delete --compress --owner /packages/jenkins/ /packages/jenkins_backup/
/usr/bin/rsync -avvP --rsh=ssh --partial --delete --compress --owner /packages/automation/ /istpackages/auto_backup/

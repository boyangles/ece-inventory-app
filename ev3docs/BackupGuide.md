# Backup Admin Guide

This guide will explain how to back up your database using rsnapshot on a separate server and notify admin through emails on success or failure.

Please follow the steps below to setup your separate server.
1. Obtain a separate server with unique admin credentials, different from your production server credentials. We have used a Duke Colab Server, on a Debian 8 Jessie environment.
2. Switch to your root user with sudo -i. Generate SSH keys and add them to your production server.
3. Download rsnapshot with `apt-get install rsnapshot`
4. Create /root/.pgpass with your host:port:databasename:password (ex. localhost:*:ece_inventory_production:yourpassword)
5. Create a backup shell script in /usr/local/bin/backup.sh
6. Add these lines (Change your host, user, database name, and email as needed)
```
#!/bin/bash                                                                                                                                         
export PGPASS=/root/.pgpass

pg_dump -w -h colab-sbx-114.oit.duke.edu -U bitnami ece_inventory_production > postgresql-dump.sql

if [ "$?" -ne 0 ]
then
    mail -s "Backup Failed" email@example.edu <<< "Database ece_inventory_production back failed. See /var/log/rsnapshot.log for more details"
    exit 1
else
    /bin/chmod 644 postgresql-dump.sql
    gzip postgresql-dump.sql
    mail -s "Backup Successful" email@example.edu <<< "Database ece_inventory_production backup was successful."
fi
```
7. Edit your /etc/rsnapshot.conf file to suit your needs. Enable ssh, edit backup times, and enable a backup script:
`backup_script		/usr/local/bin/backup.sh						localhost/postgres`
8. Edit your /etc/cron.d/rsnapshot cron job to reflect your backup times in rsnapshot.conf.

Follow this guide if errors occur. https://www.howtoforge.com/set-up-rsnapshot-archiving-of-snapshots-and-backup-of-mysql-databases-on-debian

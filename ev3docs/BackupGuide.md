# Backup Admin Guide

This guide will explain how to back up your database using rsnapshot on a separate server and notify admin through emails on success or failure.

Please follow the steps below to setup your separate server.
1. Obtain a separate server with unique admin credentials, different from your production server credentials. We have used a Duke Colab Server, on a Debian 8 Jessie environment.
2. Switch to your root user with sudo -i. Generate SSH keys and add them to your production server.
3. Download rsnapshot with `apt-get install rsnapshot`
4. Create /root/.pgpass with your host:port:databasename:username:password (ex. localhost:*:yourdatabase_name:yourusername:yourpassword)
5. Create a backup shell script in /usr/local/bin/backup.sh
6. Add these lines (Change your host, user, database name, and email as needed)
```
#!/bin/bash                                                                                                                                         
export PGPASS=/root/.pgpass

ssh user@productionserver pg_dump database_name > postgresql-dump.sql

if [ "$?" -ne 0 ]
then
    mail -s "Backup Failed" email@example.edu <<< "Database db backup failed. See /var/log/rsnapshot.log for more details"
    exit 1
else
    /bin/chmod 644 postgresql-dump.sql
    gzip postgresql-dump.sql
    mail -s "Backup Successful" email@example.edu <<< "Database db backup was successful."
fi
```
7. Edit your /etc/rsnapshot.conf file to suit your needs. Enable ssh, edit backup times, and enable a backup script:
`backup_script		/usr/local/bin/backup.sh						localhost/postgres`
8. Edit your /etc/cron.d/rsnapshot cron job to reflect your backup times in rsnapshot.conf.

Follow this guide if errors occur. https://www.howtoforge.com/set-up-rsnapshot-archiving-of-snapshots-and-backup-of-mysql-databases-on-debian

### To set up email:
Ensure exim4 is downloaded. Default configuration is currently being used. If errors occur, check configuration with
`dpkg-reconfigure exim4-config`. Ensure server configuration allows mail to be sent. 


### To Restore Database:
1. Copy your desired postgres-dump.sql (run `gunzip postgres-dump.sql.gz` to unzip file) file to your production server with scp `scp /path/to/dump/postgres-dump.sql user@hostname:~`
2. Restart postgresql and stop nginx on production to ensure all connections are severed
3. Drop your production database with `rails db:drop DISABLE_DATABASE_ENVIRONMENT_CHECK=1`.
4. Create database `rails db:create`
5. Restore backup `psql dbname < postgresql-dump.sql`
6. Restart nginx server. 
If desired, run the restoration with flag `-1`, which will ensure that the backup is valid. If the backup has any errors, the process will terminate and rollback the original database.

Helpful hints:
- rsnapshot will store your backups by default in /var/cache/rsnapshot
- rnapshot.conf is located in /etc/rsnapshot.conf
- Check logs for successful dump - /var/log/rsnapshot.log
- Check syslog to verify cron jobs are running - /var/log/syslog
- For email port issues: http://www.thegeekstuff.com/2014/02/enable-remote-postgresql-connection/?utm_source=tuicool
- Setting up rsnapshot https://www.howtoforge.com/set-up-rsnapshot-archiving-of-snapshots-and-backup-of-mysql-databases-on-debian, http://rsnapshot.org/rsnapshot/docs/docbook/rest.html

#!/bin/bash

# This script to be called by crontab regularly to back up the latest
# minecraft world files.  Edit the crontab by typing
# crontab -e
# and at the end add line(s) like the below example to run this backup script.
# The 0's mean on the 0 minute of the specified hours; the 7 and 19 mean
# the 7th and 19th hours of each day (7am, 7pm), and the remaining *'s mean
# to run it every day.  This script will only run if someone has signed into
# the minecraft server while irc.rb is operational. It will not perform backup
# if no player has signed into the minecraft server since the last backup.

#  The example crontab entries:
#  0  7 * * * /home/david/mcserver/backup.sh
#  0 19 * * * /home/david/mcserver/backup.sh


FILE="$HOME/mcserver/maybackup.0"
if [ -e $FILE ]; then
  echo Backing up server
  service minecraft backup
  rm $FILE
fi

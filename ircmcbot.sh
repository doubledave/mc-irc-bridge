#!/bin/bash
# Sets up and launches Ruby IRC bot to minecraft bridge. Minecraft needs to be already
#   running. Start with "service minecraft start"

PIPE="console.pipe"

cd $HOME/mcserver/

if [ -e $PIPE ]; then
  rm $PIPE
fi
mkfifo $PIPE

ruby irc.rb -s irc.sinsira.net -c minecraft -f $PIPE -l logs/latest.log -n mcbot &

while true
do
  screen -r minecraft_server -p 0 -X stuff "$(cat < $PIPE) $(printf '\r')"
done

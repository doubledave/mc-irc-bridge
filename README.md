# mc-irc-bridge

A minecraft server to IRC channel bridge bot

Setup/Usage:
------------

Copy file "minecraft" to /etc/init.d/

Customize this file as follows:

* Service: the .jar filename of the main minecraft server executable
* Username: the user account name that minecraft is running as
* World: the name of the subdirectory where the world files are stored
* Mcpath: the location where the minecraft server is located and runs from
* Backuppath: the location where the backup tar.gz files are to be kept
* Maxheap: Maximum number of megabytes java is allowed to allocate
* Minheap: Initial number of megabytes java is allowed to allocate
* CPU_count: Set this between 1 and the number of cores available

Start the minecraft server by typing `service minecraft start`

Check on it by either `tail -f logs/latest.log` and ctrl-c to exit out of tail, or `screen -r minecraft_server` then ctrl-a d to exit.

After minecraft is confirmed to have started properly, customize the line in ircmcbot.sh that starts with `ruby` as follows:

* after -s: irc server name. Currently set to use port default non-ssl irc port 6667
* after -c: irc channel name without the # in front of it
* after -l: the relative path to the log file; may be `server.log` or `logs/latest.log` depending on the minecraft server version used.
* after -n: the bot's nickname in irc

Run `./ircmcbot.sh` to set up the fifo pipe used for sending instructions and IRC messages to the minecraft server and launch the irc bot bridge.

This ruby bot was created by John Hawthorn. This code was taken from [John's website](https://www.johnhawthorn.com/2011/06/minecraft-to-irc-bridge/).

The init script for using screen to init/launch/communicate with/maintain the minecraft server process was taken from [Server_starup_script](http://minecraft.gamepedia.com/Tutorials/Server_startup_script).

Requirements:
-------------

* A computer capable of being used as a minecraft server (Most kinds of Linux should work)
* ruby
* python
* screen
* openjdk-7-jdk (for running minecraft itself)

Installing a minecraft server from scratch:
-------------------------------------------

Install your OS. Example: [Ubuntu Server 16.04.1 LTS](https://wiki.ubuntu.com/XenialXerus/ReleaseNotes)  
Recommended: After a fresh OS install, implement a persistent firewall to avoid attacks from malware and hackers.  [Decent iptables tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-iptables-on-ubuntu-14-04)  Allow these ports:

* `22` or whichever port you use to SSH into the server
* `25565` to allow the minecraft clients programs to connect
* `80` and/or `443` if you will be serving http/https pages from this server
* `8123` **if** you'll be using a dynmap minecraft plugin with its default port
* Any other ports belonging to services you intend to run from this server
* ICMP ping if you want this server to appear invisible to nmap and other portscanners that are operated by amateur hackers known as script kiddies

Install fail2ban to automatically configure iptables firewall to drop packets to ip addresses that attempt ssh brute force hacking attempts.  Wrong password 5 times will cause the server to appear to be offline for 5 minutes. Besides using the package manager to install, no further configuration is necessary. `sudo apt install fail2ban`  
Create a user account specifically for running minecraft and related services: `sudo adduser mc`  
Temporarily give mc account sudo access: `sudo adduser mc sudo`  
Create directories `/home/mc/mcserver` and `/home/mc/mcbackup`
Install dependencies: `sudo apt install default-jdk ruby screen`  
Obtain the actual minecraft server software in the form of a single .jar file and put it in the directory designated to run minecraft from Example what I'm currently running when this README.md was updated: [Spigot 1.9](https://getbukkit.org/spigot) in /home/mc/mcserver/  
Copy init script file `minecraft` to /etc/init.d/ and edit it to customize it for your configuration as described in the top of this README.  
Copy `backup.sh`, `ircmcbot.sh`, and `irc.rb` into mcserver directory `/home/mc/mcserver`  
Edit ircmcbot.sh to customize for whichever IRC server, channel, and bot nickname you choose. See above for instructions.  
Transfer any minecraft config files, world directories, and plugins.  
Be sure to do this while not in a **screen** session: test start the minecraft service: `service minecraft start`  
Check the status of the minecraft server or type in minecraft server commands like to whitelist users (don't use preceding forward slash): `screen -r minecraft` - to get back to normal shell, press Ctrl-a then x - Note: as long as you're in this screen session, the IRC bridge only works 1-way so be sure to Ctrl-a x out of this screen session.
While not in screen (don't use Ctrl-a then n from the existing minecraft service screen session), create a new screen session for running the IRC bridge. `screen` then `./ircmcbot.sh` - You may ctrl-a n from this screen session if you'd like. If you've disconnected from it with ctrl-a x or your ssh session closed/reset, you can get back in with `screen -r p`<tab to autocomplete>  
After starting a minecraft service instance is confirmed to work, test that performing backups on command works properly.  `touch /home/mc/mcserver/maybackup.0` - This file is generated by irc.rb whenever any minecraft client successfully logs into the server and is deleted when a backup is performed, and backup is skipped if the file is missing.  Now run `./backup.sh` and after a minute or so check in /home/mc/mcbackup to be sure the world backups are there and correct in a compressed format.
Set up cron to autolaunch mc upon machine startup and perform daily backups: `crontab -e` to edit cron. At the bottom enter the lines ` @reboot    /home/mc/mcserver/launchmcserver.sh` and ` 0 7 * * * /home/mc/mcserver/backup.sh` - this causes it to perform a daily backup a 7:00am but only if someone has signed in with a minecraft client since the previous backup.  Create multiple lines to backup multiple times per day. Save & exit.  
Note: I do not yet have a way of autostarting the minecraft to irc bridge bot; each time the server boots it will start minecraft itself, but you'll need to manually do the following:
* ssh in as the mc user
* start new screen session: `screen`
* while in screen: `~/mcserver/ircmcbot.sh`
* then you may optionally ctrl-a x to close the screen session and `exit` - or just close your ssh session.

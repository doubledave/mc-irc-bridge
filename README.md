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

Initially this does not yet work as-is. I will later update the code to what works for me and then will provide detailed installation instructions.

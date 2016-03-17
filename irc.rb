#!/usr/bin/env ruby
# Original script from https://www.johnhawthorn.com/2011/06/minecraft-to-irc-bridge/
# Modified on 2016-03-08 for https://github.com/doubledave/mc-irc-bridge

require 'socket'
require 'uri'
require 'fileutils' #03/16/2016 upon user login create a file and not care if it
                    #           already exists.  Existence of file will indicate
                    #           to the backup utility that  during the scheduled
                    #           backup, it may proceed; non-existance of it will
                    #           indicate that no one has logged in  and there is
                    #           no reason to perform the backup at that time.

class MinecraftIrcBot
  def initialize(options)
    uri = URI.parse("irc://#{options[:server]}")
    @channel = options[:channel]
    @socket = TCPSocket.open(uri.host, uri.port || 6667)
    @mclog = IO.popen("tail -f -n0 '#{options[:log]}'", "r")
    @name = options[:name]
    @pipe = options[:pipe]
    say "NICK #{@name}"
    say "USER #{@name} #{@name} #{@name} :#{@name}\r\n" #not sure if this modification was necessary; was troubleshooting problem with it failing to join the channel; fixed in line # 62.
    say "JOIN ##{@channel}"
  end

  def say(msg)
    puts msg
    @socket.puts msg
  end

  def say_to_chan(msg)
    say "PRIVMSG ##{@channel} :#{msg}"
  end

  def say_to_minecraft(msg)
    msg = "say #{msg}"
    puts msg

    File.open(@pipe, "w") do |console|
      console.puts msg
    end
  end

  def run
    loop do
      read, write, error = IO.select([@socket, @mclog])
      if read.include? @socket
        msg = @socket.gets

        # connection lost
        return unless msg

        case msg.strip
        when /^PING :(.+)$/i
          say "PONG #{$1}"
        when /^:(.+?)!.+?@.+?\sPRIVMSG\s.+?\s:(.+)$/i
          say_to_minecraft("<#{$1}> #{$2}")
        end
        # The below 4 lines were added to make it wait to join the channel until after the IRC server is ready.
        # This fix was borrowed from line 78 of https://github.com/nerdinand/ruby-irc-bot/commit/d0fd2993a293d91a07261265ae9d343fba8cf56d#diff-d91d2f33156e2aee7144289c76bb8404R78
        if !@joined && msg.include?("MODE #{@name}")
          say "JOIN ##{@channel}"
          @joined = true
        end

      end

      if read.include? @mclog
        msg = @mclog.gets
        msg.gsub!(/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} /, '')
        case msg.strip
        when /^\[INFO\] ([a-z0-9]*) lost connection/i
          say_to_chan("#{$1} has left")
        when /^\[INFO\] ([a-z0-9]*)\[[^\]]*\] logged in/i # modified to work with minecraft server version I've been using
          say_to_chan("#{$1} has joined")
          FileUtils.touch('maybackup.0')      # file to be removed upon successful backup
        when /^\[INFO\] <([a-z0-9]*)> (.*)$/i
          say_to_chan("<#{$1}> #{$2}"[0..-4]) # modified to strip last 3 (garbage) characters
        end
      end
    end
  end

  def quit
    say "PART ##{@channel} :bye bye"
    say 'QUIT'
  end
end


def parse
  require 'optparse'
  options = {}
  optparse = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} options"

    opts.on("-s", "--server SERVER", "IRC server") do |v|
      options[:server] = v
    end
    opts.on("-c", "--channel CHAN", "IRC channel") do |v|
      options[:channel] = v
    end
    opts.on("-f", "--fifo FIFO", "named pipe into minecraft server's console") do |v|
      options[:pipe] = v
    end
    opts.on("-l", "--log LOG", "minecraft servers's log file for reading") do |v|
      options[:log] = v
    end

    options[:name] = "mcirc"
    opts.on("-n", "--name NAME", "name of the irc user") do |v|
      options[:name] = v
    end
  end
  begin
    optparse.parse!

    required = [:server, :channel, :pipe, :log]
    required.each do |arg|
      raise OptionParser::MissingArgument, arg if options[arg].nil?
    end
  rescue OptionParser::InvalidOption, OptionParser::MissingArgument
    puts $!.to_s
    puts optparse
    exit 1
  end
  options
end

def run
  options = parse
  bot = MinecraftIrcBot.new(options)

  trap("INT"){ bot.quit }

  bot.run
end

run



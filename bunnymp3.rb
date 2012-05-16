#!/usr/bin/env ruby
# encoding: utf-8

require 'logger' #for debugging purposes
require 'digest' #for additional checksuming requirement if needed
require 'bunny'  #core rabbitmq gem

#some param might required at other rb files. 
HOST = "localhost"
USER = "guest"
PASS = "guest"
PORT = 5672
SSL  = false

# complusory 
EXCH = "mp3"

###NOTE###
#@queue.message count gives up somethings, guessing bunny has bug.


class Bunnymp3
  def initialize
    #start bunny
    @bunny = Bunny.new(:host => HOST, :user => USER, :pass => PASS, :port => PORT, :ssl => SSL)
    @bunny.start

    #create an exchange with name and type
    @exch = @bunny.exchange(EXCH, :type => :fanout)

    #get a network id by using ifconfig, under ubuntu.
    @hwaddr = ((`ifconfig | grep "HWaddr" | rev |  sed 's/^[ ]*//' | cut -d " " -f 1 | rev`.strip).split(":") * "")
    #bind a queue to the exchange
    @queue = @bunny.queue(@hwaddr)
    @queue.bind(@exch)
  end
  
  #called by publisher
  def publish_file fn
    @exch.publish(get_file(fn))
  end

  #called upon playback daemons (as the consumers)
  def playback 
    @queue.subscribe(:consumer_tag => @hwaddr) do |msg|
      count = @queue.default_consumer.message_count
      content = msg[:payload]
      puts content.class
      #if content is a integer, then it is a volume change message.
      if content.is_a?(Fixnum) or content.length <=3
        set_system_volume content
      else
        filename = save_file content
        play_file filename, count
      end
    end
  end

  def set_system_volume vol #0-100
    vol = vol.to_i
    @master_vol ||= 100
    @pcm_vol ||=100
    @pcm_vol = vol

    @pcm_vol = 100 if @pcm_vol > 100
    @pcm_vol = 0 if @pcm_vol == 0

    system("amixer -c 0 sset Master #{@master_vol}%")
    system("amixer -c 0 sset PCM #{@pcm_vol}%")
  end

  #called by external, vol is a Int
  def set_bunny_volume vol
    @exch.publish(vol.to_i) 
  end

  def get_file fn
    File.read(fn)
  end

  def save_file content, filename = nil
    @filename ||= "/tmp/"+ Time.now.to_i.to_s + ".mp3"
    if filename.nil? 
      filename = @filename #is default filename.
    end

    f=File.open(filename, "w"){|f| f.write content}
    filename
  end

  def play_file filename, items = "Unkonwn"
    Bunnymp3.log "Playing back new item #{filename}, #{items} items played already."
    `mpg123 -q #{filename}`
  end


  def self.hexmd5 str
    Disgest::MD5::hexdigest str
  end

  def self.log str, error_level=2
    str = str.to_s
    @@counter ||=0
    @@logger  ||= Logger.new STDOUT
    str="" if str.nil?
    str = Time.now.to_s + "|" + (@@counter+=1).to_s+ "|" + str
    if error_level > 1
      STDOUT.puts str
      #@logger.warn str
    else
      @@logger.info str
    end
  end
end

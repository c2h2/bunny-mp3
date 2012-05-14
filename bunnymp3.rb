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
QUE  = "mp3"

###NOTE###





class Bunnymp3
  def initialize
    #start bunny
    @bunny = Bunny.new(:host => HOST, :user => USER, :pass => PASS, :port => PORT, :ssl => SSL)
    @bunny.start

    #create an exchange with name and type
    @exch = @bunny.exchange(EXCH, :type => :fanout)
    #bind a queue to the exchange
    @queue = @bunny.queue(QUE)
    @queue.bind(@exch)

    @hwaddr = ((`ifconfig | grep "HWaddr" | rev |  sed 's/^[ ]*//' | cut -d " " -f 1 | rev`.strip).split(":") * "")
    

  end
  
  #called by publisher
  def publish_file fn
    @exch.publish(get_file(fn))
  end

  def receive_file 


  end

  #called upon playback daemons (as the consumers)
  def playback 
    @queue.subscribe(:consumer_tag => @hwaddr) do |msg|
      count = @queue.default_consumer.message_count
      content = msg[:payload]
      filename = save_file content
      play_file filename, count
    end
  end

  def change_volume

  end

  def get_volume

  end

  def get_file fn
    File.read(fn)
  end

  def save_file content, filename = nil
    if filename.nil? 
      filename = "/tmp/"+ Time.now.to_i.to_s + ".mp3"
    end
    f=File.open(filename, "w"){|f| f.write content}
    filename
  end

  def play_file filename, items = "Unkonwn"
    Util.log "Playing back new item #{filename}, #{items} items played already"
    `mpg123 -q #{filename}`
  end


end



class Util
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
      #@logger.add str
    else
      @@logger.info str
    end
  end
end

###AUX classes ###
class Stopwatch
  def initialize
    start
  end

  def start
    @t0 = Time.now
  end

  def end
    @t1 = Time.now
    @t1 - @t0
  end

  def self.ts
    Time.now.to_i.to_s
  end

  def self.ts2
    t=Time.new.to_i.to_s
    [t.slice(0..6), t.slice(7..-1)]
  end
end

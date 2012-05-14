bunny-mp3
============

broadcast/transmitting mp3 to client queue and playback on linux machines.

pre-requirments
===========

install rabbit-server, mpg123 and bunny gem, for example on ubuntu machine would be:

    sudo apt-get isntall rabbitmq-server mpg123
    gem install bunny



on the emitter side
===================

+ configure rabbitmq-server address, and run emit_mp3.rb
+ run by: ruby emit_mp3.rb mp3file.mp3


on the receive side
===================

+ configure rabbit server address in the mp3_daemon.rb
+ run by: ruby mp3_deamon.rb



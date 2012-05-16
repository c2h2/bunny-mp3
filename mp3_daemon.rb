#!/usr/bin/env ruby
# encoding: utf-8

require_relative "bunnymp3.rb"

bm = Bunnymp3.new
bm.set_system_volume 100
bm.playback

#!/usr/bin/env ruby
# encoding: utf-8

require_relative "bunnymp3.rb"

if ARGV[0].nil?
  puts "Missing ARGV[0] as mp3 file path.\nUsage: ruby emit_mp3.rb mp3file.mp3"
  exit 1
end

bm = Bunnymp3.new
bm.publish_file ARGV[0] 

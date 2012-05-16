#!/usr/bin/env ruby
# encoding: utf-8

require_relative "bunnymp3.rb"

if ARGV[0].nil?
  puts "Missing ARGV[0] as volume\nUsage: ruby change_volume.rb 30"
  exit 1
end

bm = Bunnymp3.new
bm.set_bunny_volume ARGV[0] 

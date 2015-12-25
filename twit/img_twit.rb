#!/usr/bin/env ruby 

require "twitter"
require "optparse"
require File.expand_path(File.dirname(__FILE__)+"/"+"twit_token.rb")

def twitimg(msg = "Hello World!!!",img_uri="./")

  client = Twitter::REST::Client.new do |config|
    config.consumer_key = TwitKey[:consumer_key]
    config.consumer_secret = TwitKey[:consumer_secret]
    config.access_token        = TwitKey[:access_token]
    config.access_token_secret = TwitKey[:access_token_secret]
  end
  
  client.update_with_media(msg,open(img_uri))
end


opt = OptionParser.new 

OPT = {} 
opt.on("--img=[img_path]") {|v| OPT[:img] = v}
opt.on("--message=[string]") {|v| OPT[:message] = v}
opt.parse!(ARGV)

p OPT
if !OPT.has_key? :img
  print "No image file" 
  exit(0)
end

OPT[:message] = nil if !OPT.has_key? :message


twitimg(OPT[:img],OPT[:message])



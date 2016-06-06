#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#

require "pi_piper"
require File.expand_path(File.dirname(__FILE__)+"/"+"hmz.rb")
require "optparse"
include Math
include HMZ433a1

=begin
# parameter
Ri = 12.0
B = 3950.0
R0 = 50
T0 = 25.0 + 273.15


def mcpConvR(x)
  # SPI入力値から抵抗値を計算
  return (1024-x).to_f / x * Ri
end

def res2temp(rs)
  # 抵抗値から温度を計算
  return B*T0/(T0*log(rs/R0) + B)
end
=end
opt = OptionParser.new 

OPT = {} 
opt.on("--loop") {OPT[:loop] = true}
opt.on("--test") {OPT[:test] = true}
opt.on("--hour=[duration]") {|t| OPT[:hour] = t.to_i}
opt.parse!(ARGV)

OPT[:hour] = 0 if !OPT.has_key? :hour

start_time = Time.now 

PiPiper::Spi.begin do |spi|

  loop do 
  
    rs = []
    10.times do 
      raw = spi.write [0x68,0]
      
      rs <<  mcpConvR( (raw[0]*256 + raw[1]) &0x3FF,10) 
    
      sleep 1
    end
    rs_ave = 0.0
    rs.each{|m| rs_ave += m}
    rs_ave /= rs.size
    
    temp = resister2temp(rs_ave) - 273.15
    
    # output 
    date = Time.now 
    print (date+9*3600).strftime("%H:%M:%S") ,"\t"
    printf("%5.2f\n",temp) 

    wait_time = 50 - date.sec
    wait_time += 10 if wait_time < 0

    break if date - start_time > OPT[:hour] * 3600 

    sleep wait_time 
    
  end
end



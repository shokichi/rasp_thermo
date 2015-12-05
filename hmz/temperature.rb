#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#

require "pi_piper"

include Math

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


PiPiper::Spi.begin do |spi|

  (6*60).times do 
  
    rs = []
    10.times do 
      raw = spi.write [0x68,0]
      
      rs <<  mcpConvR( (raw[0]*256 + raw[1]) &0x3FF) 
    
      sleep 1
    end
    rs_ave = 0.0
    rs.each{|m| rs_ave += m}
    rs_ave /= rs.size
    
    temp = res2temp(rs_ave) - 273.15
    
    # output 
    date = Time.now 
    print (date+9*3600).strftime("%H:%M:%S") ,"\t"
    printf("%5.2f\n",temp) 

    wait_time = 50 - date.sec
    wait_time += 10 if wait_time < 0
    sleep wait_time 
    
  end
end



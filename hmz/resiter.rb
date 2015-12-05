#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "pi_piper"

include Math


def mcpConvR(x,ref_R)
  # SPI入力値から抵抗値を計算
  return (1024-x).to_f / x * ref_R
end


# parameter
ref_R = 12.0

PiPiper::Spi.begin do |spi|

  10.times do 
    raw = spi.write [0x68,0]
    
    rs = mcpConvR( (raw[0]*256 + raw[1]) &0x3FF,ref_R ) 
    
    print rs ,"\n"

    sleep 1
  end

end



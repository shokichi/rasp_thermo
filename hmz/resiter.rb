#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "pi_piper"

include Math


def mcpConvR(x,ref_R)
  # SPI入力値から抵抗値を計算
  return (1024-x).to_f / x * ref_R
end

def mcpConvV(x,ref_V)
  return x.to_f/1024*ref_V
end

# parameter
ref_R = 12.0
ref_V = 5.0
PiPiper::Spi.begin do |spi|

  10.times do 
    ch0 = spi.write [0b1101000,0]
    ch1 = spi.write [0b1111000,0]

    
    rs0 = mcpConvR( (ch0[0]*256 + ch0[1]) &0x3FF,ref_R ) 
    rs1 = mcpConvV( (ch1[0]*256 + ch1[1]) &0x3FF,ref_V )   
    
    print rs0 ,"\t"
    print rs1 ,"\n"

    sleep 1
  end

end



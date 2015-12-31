#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# calcuration humidity
# HMZ 433a1

require "optparse"
include Math


=begin
Reference data 
    |   10,   15,   20,   25,   30,   35,   40
 ------------------------------------------------
 20 | 0.75, 0.72, 0.69, 0.66, 0.62, 0.59, 0.55
 30 | 1.03, 1.00, 1.00, 0.99, 0.96, 0.93, 0.90
 40 | 1.32, 1.30, 1.31, 1.32, 1.30, 1.28, 1.25
 50 | 1.64, 1.63, 1.64, 1.65, 1.64, 1.63, 1.61
 60 | 1.97, 1.97, 1.98, 1.98, 1.98, 1.98, 1.96
 70 | 2.30, 2.30, 2.31, 2.31, 2.31, 2.31, 2.30
 80 | 2.64, 2.64, 2.63, 2.64, 2.63, 2.63, 2.61
 90 | 2.97, 2.96, 2.94, 2.97, 2.94, 2.92, 2.90 

=end

OPT={}
OPT[:test] = false
opt=OptionParser.new

opt.on("--test"){OPT[:test] = true}
opt.parse!(ARGV)


ref_data = {
  temperature:[10, 15, 20, 25, 30, 35, 40],
  humidity:[20, 30, 40, 50, 60, 70, 80, 90],
  "10"=>[0.75, 1.03, 1.32, 1.64, 1.97, 2.30, 2.64, 2.97],
  "15"=>[0.72, 1.00, 1.30, 1.63, 1.97, 2.30, 2.64, 2.96],
  "20"=>[0.69, 1.00, 1.31, 1.64, 1.98, 2.31, 2.63, 2.94],
  "25"=>[0.66, 0.99, 1.32, 1.65, 1.98, 2.31, 2.64, 2.97],
  "30"=>[0.62, 0.96, 1.30, 1.64, 1.98, 2.31, 2.63, 2.94],
  "35"=>[0.59, 0.93, 1.28, 1.63, 1.98, 2.31, 2.63, 2.92],
  "40"=>[0.55, 0.90, 1.25, 1.61, 1.96, 2.30, 2.61, 2.90]
}



def linear_estimate(y, x1, y1, x2, y2)
  # 線形を仮定して値を推定
  # x = \frac{ x_1(y_2 - y) - x_2(y_1 - y) }{y_2 - y_1}

  return (x1*(y2 - y) - x2*(y1 - y))/(y2 - y1)
end

def gen_pdev_vect(x1=[],x2=[],w1,w2)
  return 0 if x1.size != x2.size 

  result = []
  x1.size.times do |n|
    result << (x1[n]*w2 + x2[n]*w1)/(w1 + w2)
  end
  
  return result 
end

def search_near_index(ref=[],val)
  result = []

  (ref.size-1).times do |n|
    result = n, n+1 if (ref[n]-val)*(ref[n+1]-val) <= 0 
  end

  if result.empty?
    result = 0, 0
    result = -1, -1 if ((ref[0]-val)/(ref[-1]-val)).abs > 1 
  end

  # return [index]
  return result
end

def search_near_value(ref=[],val)
  t1, t2 = search_near_index(ref,val)
  return ref[t1], ref[t2]
end

def calc_ratio(val,x1,x2)
  del = x2-x1
  if del == 0 
    return 1,1 
  else
    return (val-x1)/del, (x2-val)/del
  end
end


def volt2humidity_hmz(volt,temp)
  # Main
  ref_temp = search_near_value(ref_data[:temperature], temp)

  ratio = calc_ratio(temp,ref_temp[0],ref_temp[1])

  ref_volt_vect = gen_pdev_vect(ref_data[ref_temp[0].to_s], ref_data[ref_temp[1].to_s],ratio[0],ratio[1])

  hum1, hum2 = search_near_index(ref_volt_vect,volt)

  return linear_estimate(volt,ref_data[:humidity][hum1],ref_volt_vect[hum1],ref_data[:humidity][hum2],ref_volt_vect[hum2])
    
end


# Main
if OPT[:test]
  temp = 15.0
  volt = 1.00
  volt2humidity_hmz(volt,temp)
end

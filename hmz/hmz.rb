#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#

require "pi_piper"
include Math

module HMZ433a1
  #################################
  ## Temperature
  #################################
  
  # constats    
  Ri = 12.0
  Vi = 5.0
  B = 3950.0
  R0 = 50
  T0 = 25.0 + 273.15
  
  # register
  def mcpConvR(x,bit)
    # SPI入力値から抵抗値を計算
    return (2**bit-x).to_f / x * Ri
  end

  # Volt
  def mcpConvV(x,bit)
    # SPI入力値から電圧値を計算
    rs = mcpConvR(x,bit)
    return rs/(rs+Ri)* Vi
  end
  
  def resister2temp(rs)
    # 抵抗値から温度を計算
    return B*T0/(T0*log(rs/R0) + B)
  end
  

  ##################################
  ## Humidity 
  ##################################
  
  RefHumidity = {
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
    # 指定した比に基づいてベクトルを合成  
    return 0 if x1.size != x2.size 
    
    result = []
    x1.size.times do |n|
      result << (x1[n]*w2 + x2[n]*w1)/(w1 + w2)
    end
    
    return result 
  end
  
  def search_near_index(ref=[],val)
    # 配列中からもっとも近い値を検索
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
    # 配列中からもっとも近い値を検索
    t1, t2 = search_near_index(ref,val)
    return ref[t1], ref[t2]
  end
  
  def calc_ratio(val,x1,x2)
    # 比を計算
    del = x2-x1
    if del == 0 
      return 1,1 
    else
      return (val-x1)/del, (x2-val)/del
    end
  end
  
  def volt2humidity_hmz(volt,temp)
    # 電圧と気温から湿度を計算
    ref_temp = search_near_value(RefHumidity[:temperature], temp)
    
    ratio = calc_ratio(temp,ref_temp[0],ref_temp[1])
    
    ref_volt_vect = gen_pdev_vect(RefHumidity[ref_temp[0].to_s], RefHumidity[ref_temp[1].to_s],ratio[0],ratio[1])
    
    hum1, hum2 = search_near_index(ref_volt_vect,volt)
    
    return linear_estimate(volt,RefHumidity[:humidity][hum1],ref_volt_vect[hum1],RefHumidity[:humidity][hum2],ref_volt_vect[hum2])
    
  end
  
end 



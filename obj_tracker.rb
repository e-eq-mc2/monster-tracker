require 'rubygems'
require 'arduino_firmata'

module Ot
end

require_relative 'utils'

arduino = ArduinoFirmata.connect

puts "firmata version: #{arduino.version}"

arduino.on :analog_read do |pin, value| # analog_read event
  if pin == 0
    angle = Ot::Utils.map(value, 0, 1023, 0, 180)
    puts "analog pin #{pin} changed : #{value} #{angle}"

    arduino.servo_write 3, angle
  end

  if pin == 1
    angle = Ot::Utils.map(value, 0, 1023, 0, 180)
    puts "analog pin #{pin} changed : #{value} #{angle}"

    arduino.servo_write 5, angle
  end

end

loop do 
  #puts arduino.analog_read 0
  sleep 1
end

arduino.close

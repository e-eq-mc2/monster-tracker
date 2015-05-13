require 'rubygems'
require 'arduino_firmata'

arduino = ArduinoFirmata.connect '/dev/tty.usbmodem1421'

puts "firmata version: #{arduino.version}"

arduino.digital_write 13, true
#arduino.digital_write 13, false

arduino.close

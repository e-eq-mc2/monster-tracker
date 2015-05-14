require 'rubygems'
require 'arduino_firmata'

module Ot
end

require_relative 'utils'
require_relative 'opencv/face_detector.rb'

arduino = ArduinoFirmata.connect

puts "firmata version: #{arduino.version}"

#arduino.on :analog_read do |pin, value| # analog_read event
#  if pin == 0
#    angle = Ot::Utils.map(value, 0, 1023, 0, 180)
#    puts "analog pin #{pin} changed : #{value} #{angle}"
#
#    arduino.servo_write 3, angle
#  end
#
#  if pin == 1
#    angle = Ot::Utils.map(value, 0, 1023, 0, 180)
#    puts "analog pin #{pin} changed : #{value} #{angle}"
#
#    arduino.servo_write 5, angle
#  end
#end

SERVO_X = 3
SERVO_Y = 5

WIDTH  = 1280 / 3
HEIGHT = 1024 / 3

window = OpenCV::GUI::Window.new("face detect")

detector = Ot::FaceDetector.new(dev: 1, width: WIDTH, height: HEIGHT)

angle_x = 90.0
angle_y = 90.0

arduino.servo_write SERVO_X, angle_x.ceil
arduino.servo_write SERVO_Y, angle_y.ceil

while true
  key = OpenCV::GUI::wait_key(1)

  image = detector.detect do |cx, cy, width, height|
    dx = detector.center_x - cx
    dy = detector.center_y - cy

    ratio_x = (dx / detector.rx).abs
    ratio_y = (dy / detector.ry).abs

    da_x = (2.0 * (-(ratio_x - 1.0) ** 4 + 1.0)).ceil
    da_y = (2.0 * (-(ratio_y - 1.0) ** 4 + 1.0)).ceil

    angle_x = [angle_x + da_x, 180.0].min if dx > 0
    angle_y = [angle_y + da_y, 180.0].min if dy > 0

    angle_x = [angle_x - da_x,   0.0].max if dx < 0
    angle_y = [angle_y - da_y,   0.0].max if dy < 0

    puts "d(#{dx}, #{dy}) -> angle(#{angle_x}, #{angle_y}) +(#{da_x}, #{da_y})"

    arduino.servo_write SERVO_X, angle_x.ceil
    arduino.servo_write SERVO_Y, angle_y.ceil
  end

  window.show image

  next unless key

  case key.chr
  when "\e" then break
  end
end

arduino.close

require 'rubygems'
require 'arduino_firmata'

module Ot
end

require_relative 'utils'
require_relative 'detector'

arduino = ArduinoFirmata.connect

puts "firmata version: #{arduino.version}"

SERVO_X = 3
SERVO_Y = 5

INITIAL_ANGLE = 90

WIDTH  = 1280 / 3
HEIGHT = 1024 / 3

window = OpenCV::GUI::Window.new("face detect")

detector = Ot::Detector::Human.new(dev: 1, width: WIDTH, height: HEIGHT)

angle_x = INITIAL_ANGLE
angle_y = INITIAL_ANGLE

arduino.servo_write SERVO_X, angle_x
arduino.servo_write SERVO_Y, angle_y

while true
  key = OpenCV::GUI::wait_key(1)

  image = detector.detect do |cx, cy, width, height|
    dx = detector.center_x - cx
    dy = detector.center_y - cy

    ratio_x = (dx / detector.rx).abs
    ratio_y = (dy / detector.ry).abs

    da_x = (2.0 * (-(ratio_x - 1.0) ** 4 + 1.0)).floor
    da_y = (2.0 * (-(ratio_y - 1.0) ** 4 + 1.0)).floor

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

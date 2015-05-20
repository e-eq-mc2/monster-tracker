require 'bundler'
Bundler.require

include ESpeak

module MT
  class << self
    def app_root
      File.expand_path(File.join "#{File.dirname(__FILE__)}", '..')
    end
  end
end

require_relative '../lib/utils'
require_relative '../lib/detector'
require_relative '../lib/sender'

WEBCAM = 0
SERVO_X = 3
SERVO_Y = 5
LED_DETECT_STATE = 8

INITIAL_ANGLE = 90
MAX_ANGLE     = 4

WIDTH  = 1280 / 3
HEIGHT = 1024 / 3

SAVE_INTERVAL = 10

window = OpenCV::GUI::Window.new("face detect")
detector = MT::Detector::Human.new(dev: WEBCAM, width: WIDTH, height: HEIGHT)

arduino = ArduinoFirmata.connect ARGV.shift

angle_x = INITIAL_ANGLE
angle_y = INITIAL_ANGLE
arduino.servo_write SERVO_X, angle_x
arduino.servo_write SERVO_Y, angle_y

arduino.pin_mode LED_DETECT_STATE, ArduinoFirmata::OUTPUT
arduino.digital_write LED_DETECT_STATE, false

Speech.new("Hello I am baymax. I'll find monsters.", voice: "en", pitch: 90, speed: 120).speak

saved_at = Time.now

while true
  key = OpenCV::GUI::wait_key(1)

  detected = false
  image = detector.detect do |cx, cy, width, height, config_file|
    dx = detector.center_x - cx
    dy = detector.center_y - cy

    ratio_x = (dx / detector.rx).abs
    ratio_y = (dy / detector.ry).abs

    da_x = (MAX_ANGLE * (-(ratio_x - 1.0) ** 4 + 1.0)).floor
    da_y = (MAX_ANGLE * (-(ratio_y - 1.0) ** 4 + 1.0)).floor

    angle_x = [angle_x + da_x, 180.0].min if dx > 0
    angle_y = [angle_y + da_y, 180.0].min if dy > 0

    angle_x = [angle_x - da_x,   0.0].max if dx < 0
    angle_y = [angle_y - da_y,   0.0].max if dy < 0

    puts "#{config_file} d(#{dx}, #{dy}) --(#{da_x}, #{da_y})-> angle(#{angle_x}, #{angle_y})"

    arduino.servo_write SERVO_X, angle_x.ceil
    arduino.servo_write SERVO_Y, angle_y.ceil

    detected = true
  end

  if detected
    #puts "#{Time.now - saved_at}"
    if Time.now - saved_at > SAVE_INTERVAL
      Speech.new("I found a monster. I am sending its picture.", voice: "en", pitch: 90, speed: 120).speak

      image_path = "#{MT.app_root}/tmp/#{MT::Utils.simple_now}.jpg"
      image.save(image_path)

      MT::Sender.send(image_path)

      saved_at = Time.now
    end
    #arduino.digital_write LED_DETECT_STATE, true
  else
    saved_at = Time.now
    #arduino.digital_write LED_DETECT_STATE, false
  end

  window.show image

  next unless key

  case key.chr
  when "\e" then break
  end
end

arduino.close

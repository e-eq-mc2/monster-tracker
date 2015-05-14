#!/usr/bin/env ruby
# face_detect.rb
require "rubygems"
require "opencv"
require "awesome_print"
require "pry"

include OpenCV

WIDTH  = 320
HEIGHT = 256

window = GUI::Window.new("face detect")
capture = CvCapture.open 0 # size: 1280 1024
capture.width  = WIDTH
capture.height = HEIGHT

detector = CvHaarClassifierCascade::load "haarcascades/haarcascade_frontalface_alt.xml"

while true
  key = GUI::wait_key(1)
  image = capture.query

  image_center_x = image.width  * 0.5
  image_center_y = image.height * 0.5

  detector.detect_objects(image) do |region|

    diff_x = image_center_x - region.center.x
    diff_y = image_center_y - region.center.y

    puts "Center #{region.center.x} #{region.center.y} #{image.width} #{image.height} #{diff_x} #{diff_y}"

    image.rectangle! region.top_left, region.bottom_right, :color => CvColor::Red
  end

  window.show image

  next unless key

  case key.chr
  when "\e" then exit
  end
end

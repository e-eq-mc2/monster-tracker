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
capture = CvCapture.open 1 # size: 1280 1024

capture.width  = WIDTH
capture.height = HEIGHT
detector = CvHaarClassifierCascade::load "haarcascades/haarcascade_eye.xml"

image_center = OpenCV::CvPoint2D32f.new(WIDTH * 0.5, HEIGHT * 0.5)
image_rotate = OpenCV::CvMat.rotation_matrix2D(image_center, 90, 1.0)

while true
  key = GUI::wait_key(1)
  image = capture.query

  img = image
    .warp_affine(image_rotate)
    .flip(:x)

  detector.detect_objects(img) do |region|
    diff_x = image_center.x - region.center.x
    diff_y = image_center.y - region.center.y

    puts "Center #{region.center.x} #{region.center.y} #{img.width} #{img.height} #{diff_x} #{diff_y}"

    img.rectangle! region.top_left, region.bottom_right, :color => CvColor::Red
  end

  window.show img

  next unless key
  case key.chr
  when "\e"
    exit
  end
end

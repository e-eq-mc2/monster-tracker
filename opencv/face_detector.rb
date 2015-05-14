#!/usr/bin/env ruby
require "rubygems"
require "opencv"

class FaceDetector
  CONFIG_FILE = "#{File.dirname(__FILE__)}/haarcascades/haarcascade_frontalface_alt.xml"

  def initialize(dev: 0, width: nil, height: nil)
    @capture = OpenCV::CvCapture.open dev # size: 1280 1024

    @capture.width  = @width  = width
    @capture.height = @height = height

    @detector = OpenCV::CvHaarClassifierCascade::load CONFIG_FILE
  end

  def center_x
    @width * 0.5
  end

  def center_y
    @height * 0.5
  end

  def detect
    image = @capture.query

    @detector.detect_objects(image) do |region|
      yield region.center.x, region.center.y, region.width, region.height

      image.rectangle! region.top_left, region.bottom_right, :color => OpenCV::CvColor::Red
    end

    image
  end
end

if __FILE__ == $0
  WIDTH  = 320
  HEIGHT = 256

  window = OpenCV::GUI::Window.new("face detect")

  detector = FaceDetector.new(dev: 0, width: WIDTH, height: HEIGHT)

  while true
    key = OpenCV::GUI::wait_key(1)

    image = detector.detect do |obj_cx, obj_cy, obj_width, obj_height|
      diff_x = detector.center_x - obj_cx
      diff_y = detector.center_y - obj_cy

      puts "Obj Center #{obj_cx} #{obj_cy} #{obj_width} #{obj_height} #{diff_x} #{diff_y}"
    end

    window.show image

    next unless key

    case key.chr
    when "\e" then exit
    end
  end
end

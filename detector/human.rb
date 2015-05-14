#!/usr/bin/env ruby
require "rubygems"
require "opencv"
require "pry"

class Ot::Detector::Human
  CONFIG_FILE = "#{File.dirname(__FILE__)}/haarcascades/haarcascade_mcs_eyepair_small.xml"

  attr_reader :width, :height

  def initialize(dev: 0, width: nil, height: nil)
    @capture = OpenCV::CvCapture.open dev
    @capture.size = OpenCV::CvSize.new(width, height)

    @detector = OpenCV::CvHaarClassifierCascade::load CONFIG_FILE

    @width  = width
    @height = height
  end

  def center_x
    width * 0.5
  end

  def center_y
    height * 0.5
  end

  def rx
    width * 0.5
  end

  def ry
    height * 0.5
  end

  def detect
    image = @capture.query
    regions = @detector.detect_objects(image).to_a

    region = regions.sort_by {|r| r.width**2 + r.height**2}.last
    if region
      yield region.center.x, region.center.y, region.width, region.height

      image.rectangle! region.top_left, region.bottom_right, :color => OpenCV::CvColor::Red
    end

    image
  end
end

if __FILE__ == $0
  WIDTH  = 320
  HEIGHT = 256

  window = OpenCV::GUI::Window.new("detector")

  detector = FaceDetector.new(dev: 0, width: WIDTH, height: HEIGHT)

  while true
    key = OpenCV::GUI::wait_key(1)

    image = detector.detect do |cx, cy, width, height|
      dx = detector.center_x - cx
      dy = detector.center_y - cy

      puts "Obj Center #{cx} #{cy} #{width} #{height} #{dx} #{dy}"
    end

    window.show image

    next unless key

    case key.chr
    when "\e" then exit
    end
  end
end

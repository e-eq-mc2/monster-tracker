#!/usr/bin/env ruby

class Ot::Detector::Human
  CONFIG_FILES = [
    "#{File.dirname(__FILE__)}/haarcascades/haarcascade_mcs_eyepair_big.xml",
    "#{File.dirname(__FILE__)}/haarcascades/haarcascade_frontalface_alt.xml",
    "#{File.dirname(__FILE__)}/haarcascades/haarcascade_mcs_eyepair_small.xml",
    #"#{File.dirname(__FILE__)}/haarcascades/haarcascade_profileface.xml",
    #"#{File.dirname(__FILE__)}/haarcascades/haarcascade_mcs_upperbody.xml",
  ]


  attr_reader :width, :height

  def initialize(dev: 0, width: nil, height: nil)
    @capture = OpenCV::CvCapture.open dev
    @capture.size = OpenCV::CvSize.new(width, height)

    @detector2config_file = {}

    @detectors = 
      CONFIG_FILES.map do |config_file|
        detector = OpenCV::CvHaarClassifierCascade::load config_file
        @detector2config_file[detector] = config_file

        detector
      end

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

    regions     = []
    config_file = nil
    @detectors.each do |detector| 
      regions = detector.detect_objects(image).to_a
      next if regions.empty?

      config_file = File.basename @detector2config_file[detector]
      break
    end

    region = regions.sort_by {|r| r.width**2 + r.height**2}.last
    if region
      yield region.center.x, region.center.y, region.width, region.height, config_file

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

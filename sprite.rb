#!/usr/bin/env ruby
# Copyright: Matthew Colyer, 2008
# License: GPLv2

require 'RMagick'
require 'find'

unless ARGV.length == 2
  puts "sprite.rb - Takes all the png images in the given directory puts and"
  puts "turns them into a single image and returns the sass rules necessary to"
  puts "use it as a sprite in css"
  puts "USAGE: sprite.rb <directory-of-images> <output-filename>"
  exit
end

OUTPUT_FILENAME = ARGV[1]

# Determine the final and width and height of the canvas.
max_y = 0
max_x = 0
images = {}
Find.find(ARGV[0]) do |path|
  if File.file?(path) and path[-3..-1] == 'png'
    image = Magick::Image.read(path).first
    max_y = image.base_rows if image.base_rows > max_y
    max_x += image.base_columns + 1
    images[File.basename(path[0..-5])] = image
  end
end

current_x = 0
canvas = Magick::Image.new(max_x, max_y)
images.each_pair do |name, image|  
  canvas.composite!(image, current_x, 0, Magick::AtopCompositeOp)
  puts "#image-#{name}"
  puts "  background:transparent url('#{OUTPUT_FILENAME}') -#{current_x}px 0px;"
  puts "  width: #{image.base_columns}px;"
  puts "  height: #{image.base_rows}px;"
  puts
  current_x += image.base_columns+1
end
canvas.write(OUTPUT_FILENAME)

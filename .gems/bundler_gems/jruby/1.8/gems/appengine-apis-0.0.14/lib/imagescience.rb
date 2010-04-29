#!/usr/bin/ruby1.8 -w
#
# Copyright:: Copyright 2009 Bas Wilbers
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'appengine-apis/images'

class ImageScience
  Image = AppEngine::Images::Image

  def self.with_image(path)
    yield ImageScience.new(Image.open(path))
  end

  def self.with_image_data(data)
    yield ImageScience.new(Image.new(data))
  end

  def initialize(image)
    @image = image
  end

  def save(path)
    File.open(path,"w") do |f|
      f.write @image.to_s
    end
  end

  def to_s
    @image.to_s
  end

  def cropped_thumbnail(size) # :yields: image
    width, height = self.width, self.height
    left, top, right, bottom, half = 0, 0, width, half, (width - half).abs / 2

    left, right = half, half + height if width > height
    top, bottom = half, half + width if height > width

    with_crop(left, top, right, bottom) do |img|
      img.thumbnail(size) do |thumb|
        yield thumb
      end
    end
  end

  def resize(width, height)
    yield @image.resize(width, height)
  end

  def thumbnail(size) # :yields: image
    width, height = self.width, self.height
    scale = size.to_f / (width > height ? width : height)
    self.resize((width * scale).to_i, (height * scale).to_i) do |image|
      yield image
    end
  end

  def with_crop(left, top, right, bottom)
    cropped = @image.crop(left.to_f / width.to_f,
                          top.to_f / height.to_f ,
                          right.to_f / width.to_f,
                          bottom.to_f / height.to_f)
    yield ImageScience.new(cropped)
  end

  def height
    @image.height
  end

  def width
    @image.width
  end
end
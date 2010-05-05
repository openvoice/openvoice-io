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

require 'java'

module AppEngine

  # = Image Manipulation on Google app Engine
  #
  # == Usage
  # Use it like this:
  #   require 'appengine-apis/images'
  #   image = AppEngine::Images.open('public/clown.jpg')
  #   image.resize(100,100)
  #   image.to_s   #or @image.data
  #   # => "data string"
  #
  # You can also make a new Image object by simply passing a data string
  #     @image = AppEngine::Images.load("data string")
  #
  # Currently all of Google's image manipulation methods except for
  # composite images.  This means you can rotate, resize, crop and flip
  # your images.  The syntax for this is really straigthforward
  #
  #   image = AppEngine::Images.load("data string")
  #   image.resize(width,height)
  #   image.resize!(width,height)
  #
  #   image.rotate(angle)
  #   image.rotate!(angle)
  #
  #   image.flip   #flips horizontal
  #   image.flip(:horizontal) #default
  #   image.flip(:vertical)
  #
  #   image.flip!(direction)
  #
  #   image.crop(leftX,topY,rightX,bottomY)
  #   image.crop!(leftX,topY,rightX,bottomY)
  #
  #   #Bonus method from google that tries to enhance colour
  #   image.i_feel_lucky
  #   image.i_feel_lucky!
  #
  # The power lies in chaining the methods:
  #   AppEngine::Images.open('public/clown.jpg').resize(100, 100).rotate(90).flip.to_s
  #
  # == Legacy
  #
  # Maby you feel that learning yet another image manipulation syntax is
  # cumbersome. I can hardly imagine that because syntax is really
  # simple. Anyway, people have numerous reasons to stick to old
  # syntaxes. The most compelling argument is not having to rewrite code
  # for something like GAE. The easier it is for people to port their
  # app to GAE the more usefull it will be.  That is why I also included
  # a simple drop-in interface for ImageScience
  #
  #   require 'imagescience.rb'
  #
  #   ImageScience.with_image('public/clown.jpg') do |img|
  #     img.cropped_thumbnail(100) do |thumb|
  #       return thumb.to_s
  #     end
  #   end
  #
  # All the methods of ImageScience are supported. It should behave
  # exactly like ImageScience does. There is however one slight
  # problem. Google App Engine apps cannot write files to the
  # filesytem. This means that the following will never work.
  #
  #   ImageScience.with_image('public/clown.jpg') do |img|
  #     img.cropped_thumbnail(100) do |thumb|
  #       thumb.save('public/clown_thumb.jpg')
  #     end
  #   end
  #
  # To overcome this I simply added a .to_s method that returns the
  # image data as a String.  You can then either directly return this
  # data, memcache it or store it through google DataStore.
  #
  # I understand that this still means you have to modify code. If you
  # still want minimal effort porting your code I suggest you
  # monkeypatch the class and add save yourself. Then you can store it
  # the way you want(probably DataStore).
  #
  # But both of these approaches leave you with a problem if you want
  # manipulate an image that you didn't include with your deploy. For
  # example a user uploaded image or a previously modified image. You
  # cannot simply write it to a tempfile and then open them with
  # ImageScience.with_image. To overcome this problem I added a simple
  # with_image variation called with_image_data. You just use it like
  # this:
  #
  #   ImageScience.with_image('public/clown.jpg') do |img|
  #     @datastring = img.to_s
  #   end
  #   #Or get your @datastring from DataStore, Memcache or post/put params
  #   ImageScience.with_image_data(@datastring) do |img|
  #     img.cropped_thumbnail(100) do |thumb|
  #       thumb.to_s
  #       # => Jeeh, another datastring let's store it safely!
  #     end
  #   end
  #
  # I realize this still means you need you sometimes have to do quite a
  # lot of work to make it work. I personally think this is not a big
  # problem as it gives your app quite some advantages. For example it
  # becomes much easier to scale to app(That is the actual reason why
  # you cannot write to filesystem). If you wanted to scale your app
  # with amazon for example you also need to modify your code cause you
  # probably want to send your images to S3.
  #
  # If you still feel that modifying your code is to much of a trouble
  # perhaps the google app engine is just nothing for you. But ofcourse
  # you can also MonkeyPatch ruby File class and use Datastore as a
  # virtual filesystem. That would be quite a cool project, you can let
  # File.open search the datastore first and then the read-only harddisk
  # (to simulate file overwriting) You can Cache things with memcache(If
  # that makes it faster). When you are done drop me a note will you?
  #
  # == Meta
  #
  # Created by Bas Wilbers
  module Images
    module IS
      import com.google.appengine.api.images.Image
      import com.google.appengine.api.images.ImagesService
      import com.google.appengine.api.images.ImagesServiceFactory
      import com.google.appengine.api.images.Transform

      Service = ImagesServiceFactory.images_service
    end

    def self.open(filename)
      Image.open(filename)
    end

    def self.load(data)
      Image.new(data)
    end

    class Image
      def self.open(filename)
        File.open(filename) do |file|
          return new(file.read)
        end
      end

      def height
        @image.getHeight
      end

      def width
        @image.getWidth
      end

      def initialize(data)
        @image =  IS::ImagesServiceFactory.make_image(data.to_java_bytes)
      end

      def apply_transform(transform)
        Image.new(data).deep_transform(transform)
      end

      def deep_transform(transform)
        IS::Service.apply_transform(transform, @image)
        self
      end

      def resize(width, height)
        apply_transform IS::ImagesServiceFactory.make_resize(width, height)
      end

      def resize!(width, height)
        @image = resize(width, height)
      end

      def rotate(degree)
        apply_transform IS::ImagesServiceFactory.make_rotate(degree)
      end

      def rotate!(degree)
        @image = rotate(degree)
      end

      def flip(direction = :horizontal)
        if direction.to_sym == :horizontal
          return apply_transform IS::ImagesServiceFactory.make_horizontal_flip
        elsif direction.to_sym == :vertical
          return apply_transform IS::ImagesServiceFactory.make_vertical_flip
        else
          raise ArgumentError, 'Direction must be :horizontal or :vertical'
        end
      end

      def flip!(direction)
        @image = flip(direction)
      end

      def crop(leftX, topY, rightX, bottomY)
        apply_transform IS::ImagesServiceFactory.make_crop(leftX, topY, rightX, bottomY)
      end

      def crop!(leftX, topY, rightX, bottomY)
        @image = crop(leftX, topY, rightX, bottomY)
      end

      def i_feel_lucky
        apply_transform IS::ImagesServiceFactory.make_im_feeling_lucky
      end

      def i_feel_lucky!
        @image = i_feel_lucky
      end

      def data
        String.from_java_bytes @image.image_data
      end
      alias :to_s :data
    end
  end
end


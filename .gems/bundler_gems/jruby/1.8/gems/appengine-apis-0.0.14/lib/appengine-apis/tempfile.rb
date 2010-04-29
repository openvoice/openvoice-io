#! /usr/bin/ruby
# Copyright:: Copyright 2009 Google Inc.
# Original Author:: Ryan Brown (mailto:ribrdb@google.com)
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
#
# Replace TempFile with a StringIO.

$" << "tempfile.rb"

require 'stringio'

TempFile = Class.new(StringIO)

class Tempfile < StringIO
  attr_reader :path

  def initialize(basename, tmpdir=nil)
    @path = basename
    super()
  end

  def unlink; end

  def close(*args)
    super()
  end

  def open; end

  alias close! close
  alias delete unlink
  alias length size

  def self.open(*args)
    if block_given?
      yield new(*args)
    else
      new(*args)
    end
  end
end

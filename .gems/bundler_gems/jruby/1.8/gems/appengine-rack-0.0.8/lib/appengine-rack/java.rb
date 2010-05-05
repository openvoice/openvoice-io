#!/usr/bin/ruby1.8 -w
#
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

require 'appengine-rack'

class JavaServlet
  def initialize(klass, options={})
    @klass = klass.to_s
    @name = (options[:name] || klass).to_s
    @wildcard = options[:wildcard]
  end
  
  def call(env)
    raise RuntimeError, "JavaServlet should be dispatched by web.xml"
  end
  
  def append_xml(doc, pattern)
    servlet = doc.add_element('servlet')
    servlet.add_element('servlet-name').add_text(@name)
    servlet.add_element('servlet-class').add_text(@klass)
    map = doc.add_element('servlet-mapping')
    map.add_element('servlet-name').add_text(@name)
    map.add_element('url-pattern').add_text(pattern.to_s)
    if @wildcard
      wildcard = doc.add_element('servlet-mapping')
      wildcard.add_element('servlet-name').add_text(@name)
      wildcard.add_element('url-pattern').add_text(
          AppEngine::Rack.make_wildcard(pattern))
    end
  end
end

class JavaServletFilter
  def self.append_xml(doc, pattern, klass, options={})
    name = options[:name] || klass
    filter = doc.add_element('filter')
    filter.add_element('filter-name').add_text(name.to_s)
    filter.add_element('filter-class').add_text(klass.to_s)
    unless pattern == '/' && options[:wildcard]
      map = doc.add_element('filter-mapping')
      map.add_element('filter-name').add_text(name.to_s)
      map.add_element('url-pattern').add_text(pattern.to_s)
    end
    if options[:wildcard]
      wildcard = doc.add_element('filter-mapping')
      wildcard.add_element('filter-name').add_text(name.to_s)
      wildcard.add_element('url-pattern').add_text(
          AppEngine::Rack.make_wildcard(pattern))
    end
  end
  
  def self.new(app, *args, &block)
    app
  end
end

class JavaContextListener
  def self.append_xml(doc, pattern, klass)
    listener = doc.add_element('listener')
    listener.add_element('listener-class').add_text(klass.to_s)
  end
  
  def self.new(app, *args, &block)
    app
  end
end

class JavaContextParams
  def self.append_xml(doc, pattern, params)
    params.each do |name, value|
      e = doc.add_element('context-param')
      e.add_element('param-name').add_text(name.to_s)
      e.add_element('param-value').add_text(value.to_s)
    end
  end
  
  def self.new(app, *args, &block)
    app
  end
end

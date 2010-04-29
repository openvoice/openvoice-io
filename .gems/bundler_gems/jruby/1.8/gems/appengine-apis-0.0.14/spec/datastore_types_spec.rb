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

require File.dirname(__FILE__) + '/spec_helper.rb'
require 'appengine-apis/datastore_types'

describe AppEngine::Datastore::Key do
  Key = AppEngine::Datastore::Key
  
  it "should support ==" do
    a1 = Key.from_path("A", 1)
    a2 = Key.from_path("A", 1)
    a1.should == a2
    a2.should.eql? a1
    a1.hash.should == a2.hash
    (a1 <=> a2).should == 0
  end

  it "should support <=>" do
    a1 = Key.from_path("A", 1)
    a2 = Key.from_path("A", 2)
    a1.should < a2
    a2.should > a1
    (a1 <=> a2).should == -1
    (a2 <=> a1).should == 1
  end
  
  it "should create from id" do
    key = Key.from_path("Foo", 27)
    key.kind.should == 'Foo'
    key.id.should == 27
    key.id_or_name.should == 27
  end
  
  it "should create from name" do
    key = Key.from_path("Bar", 'baz')
    key.kind.should == 'Bar'
    key.name.should == 'baz'
    key.id_or_name.should == 'baz'
  end
  
  it "should create with parent" do
    parent = Key.from_path("Foo", 1)
    key = Key.from_path(parent, "Bar", 2)
    key.kind.should == 'Bar'
    key.id.should == 2
    key.parent.should == parent
  end
  
  it "should support long paths" do
    key = Key.from_path('A', 1, 'B', 2, 'C', 3)
    key.kind.should == 'C'
    key.id.should == 3
    key.parent.kind.should == 'B'
    key.parent.id.should == 2
    key.parent.parent.kind.should == 'A'
    key.parent.parent.id.should == 1
  end
  
  it "should encode" do
    key = Key.from_path('Foo', 'bar')
    key.to_s.should == 'agR0ZXN0cgwLEgNGb28iA2Jhcgw'
  end
  
  it "should create from encoded" do
    decoded = Key.new('agR0ZXN0cgwLEgNGb28iA2Jhcgw')
    key = Key.from_path('Foo', 'bar')
    decoded.should == key
  end
  
end

describe AppEngine::Datastore::Entity do

  before :each do
    @entity = AppEngine::Datastore::Entity.new('Test')
  end
  
  it "should support nil" do
    @entity['nil'] = nil
    @entity.has_property?('nil').should == true
    @entity['nil'].should == nil
  end
  
  it "should support true" do
    @entity['true'] = true
    @entity['true'].should == true
  end
  
  it "should support false" do
    @entity['false'] = false
    @entity['false'].should == false
  end
    
  it "should support Strings" do
    @entity['string'] = 'a string'
    @entity['string'].should == 'a string'
  end
  
  it "should support Integers" do
    @entity['int'] = 42
    @entity['int'].should == 42
  end
  
  it "should support Floats" do
    @entity['float'] = 3.1415
    @entity['float'].should == 3.1415
  end
  
  it "should support Symbol for name" do
    @entity[:foo] = 'bar'
    @entity[:foo].should == 'bar'
    @entity['foo'].should == 'bar'
  end
  
  it "should support Text" do
    text = 'Some text. ' * 1000
    @entity['text'] = AppEngine::Datastore::Text.new(text)
    @entity['text'].should == text
    @entity['text'].class.should == AppEngine::Datastore::Text
  end
  
  it "should support Blob" do
    blob = "\0\1\2" * 1000
    @entity['blob'] = AppEngine::Datastore::Blob.new(blob)
    @entity['blob'].should == blob
    @entity['blob'].class.should == AppEngine::Datastore::Blob
  end
  
  it "should support ByteString" do
    blob = "\0\1\2"
    @entity['blob'] = AppEngine::Datastore::ByteString.new(blob)
    @entity['blob'].should == blob
    @entity['blob'].class.should == AppEngine::Datastore::ByteString
  end
  
  it "should support Link" do
    link = "http://example.com/" + "0" * 1000
    @entity['link'] = AppEngine::Datastore::Link.new(link)
    @entity['link'].should == link
    @entity['link'].class.should == AppEngine::Datastore::Link
  end
  
  it "should support Time" do
    time = Time.now - 3600
    @entity['time'] = time
    @entity['time'].to_s.should == time.to_s
    @entity['time'].class.should == Time
  end
  
  it "should support Email" do
    email = "ribrdb@example.com"
    @entity['email'] = AppEngine::Datastore::Email.new(email)
    @entity['email'].should == email
    @entity['email'].class.should == AppEngine::Datastore::Email
  end
  
  it "should support Category" do
    category = "food"
    @entity['cat'] = AppEngine::Datastore::Category.new(category)
    @entity['cat'].should == category
    @entity['cat'].class.should == AppEngine::Datastore::Category
  end
  
  it "should support PhoneNumbers" do
    number = '555-1212'
    @entity['phone'] = AppEngine::Datastore::PhoneNumber.new(number)
    @entity['phone'].should == number
    @entity['phone'].class.should == AppEngine::Datastore::PhoneNumber
  end

  it "should support PostalAddress" do
    address = '345 Spear St'
    @entity['address'] = AppEngine::Datastore::PostalAddress.new(address)
    @entity['address'].should == address
    @entity['address'].class.should == AppEngine::Datastore::PostalAddress
  end

  it "should support Rating" do
    rating = 34
    @entity['rating'] = AppEngine::Datastore::Rating.new(rating)
    @entity['rating'].rating.should == rating
    @entity['rating'].class.should == AppEngine::Datastore::Rating
  end

  it "should support IMHandle" do
    im = AppEngine::Datastore::IMHandle.new(:xmpp, 'batman@google.com')
    @entity['im'] = im
    @entity['im'].should == im
    @entity['im'].class.should == AppEngine::Datastore::IMHandle
  end

  it "should support GeoPt" do
    latitude = 32.4
    longitude = 72.2
    @entity['address'] = AppEngine::Datastore::GeoPt.new(latitude, longitude)
    @entity['address'].latitude.should be_close latitude, 0.001
    @entity['address'].longitude.should be_close longitude, 0.001
    @entity['address'].class.should == AppEngine::Datastore::GeoPt
  end

  it "should support multiple values" do
    list = [1, 2, 3]
    @entity['list'] = list
    @entity['list'].should == list
  end
  
  it "should not support random types" do
      lambda{@entity['foo'] = Kernel}.should raise_error(ArgumentError)
  end
  
  it "should support delete" do
    @entity['foo'] = 'bar'
    @entity.delete('foo')
    @entity.has_property?('foo').should == false
  end
    
  it "should support delete symbol" do
    @entity['foo'] = 'bar'
    @entity.delete(:foo)
    @entity.has_property?('foo').should == false
  end
  
  it "should support each" do
    props = {'foo' => 'bar', 'count' => 3}
    props.each {|name, value| @entity[name] = value}
    @entity.each do |name, value|
      props.delete(name).should == value
    end
    props.should == {}
  end
  
  it "should support update" do
    @entity.update('foo' => 'bar', 'count' => 3)
    @entity[:foo].should == 'bar'
    @entity[:count].should == 3
  end
  
  it "should support to_hash" do
    props = {'foo' => 'bar', 'count' => 3}
    @entity.merge!(props)
    @entity.to_hash.should == props
  end
end

describe AppEngine::Datastore::Text do
  it "should support to_s" do
    t = AppEngine::Datastore::Text.new("foo")
    t.to_s.should == t
  end
end

describe AppEngine::Datastore::Rating do
  it 'should support ==' do
    a = AppEngine::Datastore::Rating.new(27)
    b = AppEngine::Datastore::Rating.new(27)
    a.should == b
  end
  
  it 'should support <=>' do
    a = AppEngine::Datastore::Rating.new(3)
    b = AppEngine::Datastore::Rating.new(4)
    a.should be < b
    b.should be > a
  end
  
  it 'should check MIN_VALUE' do
    l = lambda {AppEngine::Datastore::Rating.new -1}
    l.should raise_error ArgumentError
  end
  
  it 'should check MAX_VALUE' do
    l = lambda {AppEngine::Datastore::Rating.new 101}
    l.should raise_error ArgumentError
  end
  
  it 'should support rating' do
    a = AppEngine::Datastore::Rating.new(33)
    a.rating.should == 33
    a.to_i.should == 33
  end
end

describe AppEngine::Datastore::GeoPt do
  it 'should support ==' do
    a = AppEngine::Datastore::GeoPt.new(35, 62)
    b = AppEngine::Datastore::GeoPt.new(a.latitude, a.longitude)
    a.should == b
  end
  
  it 'should support <=>' do
    a = AppEngine::Datastore::GeoPt.new(35, 62)
    b = AppEngine::Datastore::GeoPt.new(36, 62)
    a.should be < b
    b.should be > a
  end
  
  it 'should convert exceptions' do
    l = lambda {AppEngine::Datastore::GeoPt.new(700, 999)}
    l.should raise_error ArgumentError
  end
end

describe AppEngine::Datastore::IMHandle do
  it 'should support ==' do
    a = AppEngine::Datastore::IMHandle.new(:unknown, 'foobar')
    b = AppEngine::Datastore::IMHandle.new(:unknown, 'foobar')
    a.should == b
  end
  
  it 'should support symbols' do
    p = Proc.new do
      AppEngine::Datastore::IMHandle.new(:sip, "sip_address")
      AppEngine::Datastore::IMHandle.new(:xmpp, "xmpp_address")
      AppEngine::Datastore::IMHandle.new(:unknown, "unknown_address")
    end
    p.should_not raise_error ArgumentError
  end
  
  it 'should support urls' do
    protocol = 'http://aim.com/'
    address = 'foobar'
    im = AppEngine::Datastore::IMHandle.new(protocol, address)
    im.protocol.should == protocol
    im.address.should == address
  end
  
  it 'should convert errors' do
    l = lambda {AppEngine::Datastore::IMHandle.new 'aim', 'foobar'}
    l.should raise_error ArgumentError
  end
end

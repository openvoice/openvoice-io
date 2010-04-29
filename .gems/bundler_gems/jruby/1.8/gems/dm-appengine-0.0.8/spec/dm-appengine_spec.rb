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

require File.dirname(__FILE__) + '/spec_helper'
require 'dm-core/spec/adapter_shared_spec'

class TextTest
  include DataMapper::Resource
  
  property :id, Serial
  property :text, Text
end

class TypeTest
  include DataMapper::Resource
  
  property :name, String, :key => true
  property :time, Time
  property :date, Date
  property :datetime, DateTime
  property :bigd, BigDecimal
  property :flower, Object
  property :klass, Class
  property :list, List
  property :blob, Blob
  property :bstring, ByteString
  property :link, Link
  property :email, Email
  property :category, Category
  property :phone, PhoneNumber
  property :address, PostalAddress
  property :rating, Rating
  property :im, IMHandle
  property :point, GeoPt
  property :user, User
  # the 'key' method is already defined on DataMapper::Resource.
  property :key_property, Key
end

class Flower
  attr_accessor :color
end

class FooBar
  include DataMapper::Resource
  
  property :id, Serial
  property :string, String
end

class KeyTest
  include DataMapper::Resource
  
  property :appengine_key, Key, :key => true
  property :string, String
end

describe DataMapper::Adapters::AppEngineAdapter do
  before :all do
    AppEngine::Testing.install_test_env
    AppEngine::Testing.install_test_datastore
  end

  before :all do
    @adapter = DataMapper.setup(:default, "app_engine://memory")
    @repository = DataMapper.repository(@adapter.name)
    
    AppEngine::Testing.install_test_datastore
  end
  
  def pending_if(message, boolean = true)
    if boolean
      pending(message) { yield }
    else
      yield
    end
  end

  it_should_behave_like 'An Adapter'
  
  describe 'create' do
    it 'should support Text' do
      a = TextTest.new(:text => "a" * 1024)
      a.save
    end
  end
  
  describe 'update' do
    it 'should support Text' do
      a = TextTest.new(:text => "a" * 1024)
      a.save
      a.text = "A" * 1024
      a.save
      a.reload
      a.text.should be_a(AppEngine::Datastore::Text)
      a.text.should be_a(String)
    end
  end
  
  describe 'read' do
    it 'should support sorting by id' do
      FooBar.create(:string => 'a')
      FooBar.create(:string => 'c')
      FooBar.create(:string => 'b')
      foobars = FooBar.all(:order => [:id.desc])
      strings = foobars.map {|fb| fb.string}
      strings.should == ['b', 'c', 'a']
    end
    
    it 'should support sorting by property' do
      foobars = FooBar.all(:order => [:string])
      strings = foobars.map {|fb| fb.string}
      strings.should == ['a', 'b', 'c']      
    end
    
    it 'should support filtering by id' do
      a = FooBar.first
      a.string.should == 'a'
      b = FooBar.first(:id.gt => a.id)
      b.string.should == 'c'
    end
  end
  
  describe 'types' do
    it 'should support Date' do
      date = Date.parse('2007/12/23')
      a = TypeTest.new(:name => 'date', :date => date)
      a.save
      a.reload
      a.date.should == date
    end
    
    it 'should support Time' do
      time = Time.at(Time.now.to_i)  # Datastore store ms precision, not usec
      a = TypeTest.new(:name => 'time', :time => time)
      a.save
      a.reload
      a.time.should == time
    end
    
    it 'should support DateTime' do
      date = DateTime.parse('2007-12-23')
      a = TypeTest.new(:name => 'datetime', :datetime => date)
      a.save
      a.reload
      a.datetime.should == date
    end
    
    it 'should support BigDecimal' do
      one = BigDecimal.new('1.0')
      a = TypeTest.new(:name => 'bigd', :bigd => one)
      a.save
      a.reload
      a.bigd.should == one
    end
    
    it 'should support Object' do
      flower = Flower.new
      flower.color = 'red'
      a = TypeTest.new(:name => 'color', :flower => flower)
      a.save
      a.reload
      a.flower.color.should == flower.color
    end
    
    it 'should support Class' do
      a = TypeTest.new(:name => 'class', :klass => Flower)
      a.save
      a.reload
      a.klass.should == Flower
    end
    
    it 'should support List' do
      a = TypeTest.new(:name => 'list', :list => [1, 2, 3])
      a.save
      a.reload
      a.list.should == [1, 2, 3]
      TypeTest.all(:list => 2).should == [a]
    end
    
    it 'should support Blob' do
      a = TypeTest.new(:name => 'blob', :blob => '\0')
      a.save
      a.reload
      a.blob.should == '\0'
    end
    
    it 'should support ByteString' do
      a = TypeTest.new(:name => 'bstring', :bstring => '\0')
      a.save
      a.reload
      a.bstring.should == '\0'
    end
    
    it 'should support Link' do
      link = "http://example.com/" + "0" * 1000
      a = TypeTest.new(:name => 'link', :link => link)
      a.save
      a.reload
      a.link.should == link
    end
    
    it 'should support Email' do
      a = TypeTest.new(:name => 'email', :email => 'ribrdb@example.com')
      a.save
      a.reload
      a.email.should == 'ribrdb@example.com'
    end
    
    it 'should support Category' do
      a = TypeTest.new(:name => 'category', :category => 'tests')
      a.save
      a.reload
      a.category.should == 'tests'      
    end

    it "should support PhoneNumbers" do
      number = '555-1212'
      a = TypeTest.new(:name => 'phone', :phone => number)
      a.save
      a.reload
      a.phone.should == number
    end

    it "should support PostalAddress" do
      address = '345 Spear St'
      a = TypeTest.new(:name => 'address', :address => address)
      a.save
      a.reload
      a.address.should == address
    end

    it "should support Rating" do
      rating = 34
      a = TypeTest.new(:name => 'rating', :rating => rating)
      a.save
      a.reload
      a.rating.should == 34
    end

    it "should support IMHandle" do
      im = AppEngine::Datastore::IMHandle.new(:xmpp, 'batman@google.com')
      a = TypeTest.new(:name => 'im', :im => im)
      a.save
      a.reload
      a.im.should == im
    end

    it "should support GeoPt" do
      latitude = 32.4
      longitude = 72.2
      point = AppEngine::Datastore::GeoPt.new(latitude, longitude)
      a = TypeTest.new(:name => 'point', :point => point)
      a.save
      a.reload
      a.point.should == point
      a.point.latitude.should be_close(latitude, 0.1)
      a.point.longitude.should be_close(longitude, 0.1)
    end
    
    it "should support Key" do
      obj = AppEngine::Datastore::Entity.new('Key Test')
      AppEngine::Datastore.put obj
      key = obj.key
      a = TypeTest.new(:name => 'key', :key_property => key)
      a.save
      a.reload
      a.key_property.should == key
    end
  end
  
  describe 'primary keys' do
    before :each do 
      @resource = KeyTest.new(:appengine_key => AppEngine::Datastore::Key.from_path('KeyTests', 'Foo'))
    end
    
    it 'should support AppEngine::Datastore::Key' do
      @resource.string = 'Make sure it has some data.'
      @resource.save
      @resource.reload
      @resource.string.should == 'Make sure it has some data.'
    end
    
    it 'should be an AppEngine::Datastore::Key under the hood' do
      @resource.appengine_key.should be_a(AppEngine::Datastore::Key)
      key = @resource.appengine_key
      @resource.save
      @resource.reload
      @resource.appengine_key.should be_a(AppEngine::Datastore::Key)
      @resource.appengine_key.should == key
    end
    
    it "shouldn't save keys as actual entity properties" do
      @resource.save
      entity = AppEngine::Datastore.get(@resource.appengine_key)
      entity.should_not have_property(:appengine_key)
    end
    
    it 'should be possible to query by string' do
      @resource.string = 'Querying by string'
      @resource.save
      fetched = KeyTest.get 'Foo'
      fetched.string.should == 'Querying by string'
    end
    
    it 'should be possible save by string' do
      @resource.appengine_key = 'Bar'
      @resource.string = 'Saving by string'
      @resource.save
      fetched = KeyTest.get 'Bar'
      fetched.string.should == 'Saving by string'
      fetched.appengine_key.should be_kind_of AppEngine::Datastore::Key
    end
    
    it 'should be possible to save and query by id' do
      @resource.appengine_key = 10
      @resource.string = 'Querying by id'
      @resource.save
      fetched = KeyTest.get 10
      fetched.string.should == 'Querying by id'
      fetched.appengine_key.should be_kind_of AppEngine::Datastore::Key
    end
    
    describe 'should support creating and fetching resources by Hash' do
      it 'with parents' do
        @resource.save
        child = KeyTest.new
        child.appengine_key = {:parent => @resource.appengine_key, :name => 'Child!'}
        child.string = 'Some more data.'
        child.save
        child.reload
        child = KeyTest.get :parent => @resource.appengine_key, :name => 'Child!'
        child.string.should == 'Some more data.'
      end
      
      it 'with ids instead of names' do
        @resource.appengine_key = {:id => 5}
        @resource.string = 'Even more data.'
        @resource.save
        @resource.reload
        @resource.string.should == 'Even more data.'
      end
      
      it 'without forgetting about parents' do
        @resource.save
        child = KeyTest.new
        child.appengine_key = {:parent => @resource.appengine_key, :name => 'Child!'}
        child.appengine_key.parent.should == @resource.appengine_key
        child.string = "don't forget"
        child.save
        child.reload
        child.string.should == "don't forget"
        child.appengine_key.parent.should == @resource.appengine_key
        child.appengine_key.parent.should_not be_nil
      end
    end
    
    it 'should typecast hash values' do
      @resource.appengine_key = {:id => '5'}
      @resource.string = 'Typecasting hash values.'
      @resource.save
      fetched = KeyTest.get 5
      fetched.string.should == 'Typecasting hash values.'
      @resource.appengine_key.id.should be 5
    end
    
    it 'should allow nil (autoincrementing ids), even with parents' do
      @resource.save
      child = KeyTest.new
      child.appengine_key = {:parent => @resource.appengine_key}
      child.string = 'Should allow nil'
      child.save
      child.appengine_key.id.should_not be_nil
      child.reload
      child.string.should == 'Should allow nil'
    end
    
    it 'should work when the key is not set at all' do
      a = KeyTest.create(:string => 'Completely nil key')
      a.save
      a.reload
      a.string.should == 'Completely nil key'
      a.appengine_key.should_not be_nil
      a.appengine_key.id.should_not be_nil
      a.appengine_key.id.should be > 0
    end
    
    # Probably not comprehensive.
    # The idea is that if neither name nor id is specified,
    # leave it nil and let the key be generated when it's saved.
    it "shouldn't create serial keys until the entity is saved, even with a parent" do
      AppEngine::Datastore::Key.should_not_receive :from_path
      parent = KeyTest.create(:string => 'foo')
      key = parent.appengine_key
      key.should be_kind_of AppEngine::Datastore::Key
      key.should_not_receive :getChild
      
      child = KeyTest.create(:appengine_key => {:parent => key})
      child_key = child.appengine_key
      child_key.should be_kind_of AppEngine::Datastore::Key
      child_key.parent.should == key
      
      child_key.id.should_not be_nil
      child_key.id.should be > 0
    end
  end
end

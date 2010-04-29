#!/usr/bin/ruby1.8 -w
#
# Copyright:: Copyright 2009 David Masover
# Original Author:: David Masover (mailto:ninja@slaphack.com)
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
require 'dm-appengine/is_entity'

class VanillaTest
  include DataMapper::Resource
  is :entity
  property :string, String
end

class AppEngineResourceTest
  include DataMapper::AppEngineResource
  property :string, String
end

class HasManyTest
  include DataMapper::AppEngineResource
  property :string, String
  has n, :belongs_to_tests
end

class BelongsToTest
  include DataMapper::AppEngineResource
  property :string, String
  belongs_to :has_many_test
end

class Post
  include DataMapper::AppEngineResource
  property :title, String
  property :body, Text
  has n, :comments, :child_key => [:commentable_id]
end

class Image
  include DataMapper::AppEngineResource
  property :name, String
  property :url, Link
  has n, :comments, :child_key => [:commentable_id]
end

class Comment
  include DataMapper::AppEngineResource
  property :subject, String
  property :body, Text
  belongs_to_entity :commentable
end

class User
  include DataMapper::AppEngineResource
  property :name, String
  
  has_descendants :settings
end

class Setting
  include DataMapper::AppEngineResource
  property :value, String
end

describe 'An is(:entity) model' do
  it 'should work without anything special' do
    a = VanillaTest.create(:string => 'Plain Vanilla Test')
    a.reload
    a.string.should == 'Plain Vanilla Test'
    a.id.should_not be_nil
    a.id.should be_kind_of AppEngine::Datastore::Key
  end
  
  describe 'in a relationship' do
    before :each do
      @parent = HasManyTest.create(:string => 'the parent')
      @child = @parent.belongs_to_tests.create(:string => 'the child')
    end
    
    it 'should have the parent' do
      @child.reload
      @child.has_many_test.should == @parent
    end
    
    it 'should have the parent_id' do
      @child.reload
      @child.has_many_test_id.should == @parent.id
      @child.has_many_test_id.should be_kind_of AppEngine::Datastore::Key
    end
    
    it 'should have the child' do
      @parent.belongs_to_tests.create(:string => 'another child')
      parent = HasManyTest.get(@parent.id)
      child_one = parent.belongs_to_tests.all(:string => 'the child')
      child_one.count.should == 1
      child_one.first.string.should == 'the child'
    end
  end
  
  describe 'with a polymorphic owner' do
    before :each do
      @post = Post.create(:title => 'I saw an image today', :body => 'and it was ugly.')
      @post_comment = @post.comments.create(:subject => "No, it wasn't!", :body => 'it was beautiful!')
      @image = Image.create(:name => 'Ugly image', :url => 'http://example.com/UGLY.png')
      @image_comment = @image.comments.create(:subject => 'Beautiful', :body => 'I was touched!')
    end
    
    it 'should reload properly' do
      @post.reload.title.should == 'I saw an image today'
      @post_comment.reload.subject.should == "No, it wasn't!"
      @image.reload.name.should == 'Ugly image'
      @image_comment.reload.subject.should == 'Beautiful'
    end
    
    it 'should have the right children' do
      @post.reload
      @image.reload
      
      @post.comments.count.should == 1
      @image.comments.count.should == 1
      @post.comments.first.subject.should == @post_comment.subject
      @image.comments.first.subject.should == @image_comment.subject
    end
    
    it 'should have the right parents' do
      @post_comment.reload.commentable.should == @post
      @image_comment.reload.commentable.should == @image
    end
    
    # This can happen when you forget to set child_key.
    it "shouldn't have extra keys" do
      [@post_comment, @image_comment].each do |comment|
        properties = comment.send(:properties).map(&:name)
        properties.should include :commentable_id
        properties.should_not include :post_id
        properties.should_not include :image_id
      end
    end
  end
  
  describe 'with a parent' do
    before :each do
      @parent = VanillaTest.create(:string => 'Plain vanilla parent')
      @child = VanillaTest.create(:id => {:parent => @parent.id}, :string => 'Plain vanilla child')
    end
    
    it 'should work' do
      @parent.reload.string.should == 'Plain vanilla parent'
      @child.reload.string.should == 'Plain vanilla child'
    end
    
    it 'should have the parent' do
      @child.reload.parent.should == @parent
    end
    
    it 'should be visible with an ancestor query' do
      VanillaTest.all(:ancestor => @parent.id).should include @child
      # Note: "ancestor" queries appear to include self.
    end
    
    it 'should be visible with a "descendant" query' do
      @parent.descendants(VanillaTest).should include @child
    end
    
    # TODO: break into smaller specs
    it "shouldn't include the whole world as siblings" do
      stranger = VanillaTest.create(:string => 'Strange vanilla child')
      children = VanillaTest.all(:ancestor => @parent.id)
      children.should_not include stranger
      children.none?{|x| x.string == 'Strange vanilla child'}.should be true
      
      stranger.update(:string => 'Plain vanilla child')
      plain = VanillaTest.all(:string => 'Plain vanilla child')
      plain.should include stranger
      plain.should include @child
      
      our_plain = VanillaTest.all(:ancestor => @parent.id, :string => 'Plain vanilla child')
      our_plain.should_not include stranger
      our_plain.should include @child
    end
  end
  
  describe 'with has_descendants' do
    before :each do
      @user = User.create(:name => 'Billy')
      @setting = Setting.create(:id => {:parent => @user.id, :name => 'displayname'}, :value => 'John')
    end
    
    it 'should be possible to find the appropriate descendants' do
      @user.settings.count.should == 1
      @user.settings.first.should == @setting
      @user.settings.first.value.should == 'John'
    end
  end
end

describe DataMapper::AppEngineResource do
  it 'should work just like the vanilla test' do
    a = AppEngineResourceTest.create(:string => 'AppEngineResource test')
    a.reload
    a.string.should == 'AppEngineResource test'
  end
end
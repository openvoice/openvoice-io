module ActionView
  module Partials
   def render_partial
    #so that we do not have to load action view but can still alias this method
   end
  end
end


require 'rubygems'
require 'lib/rails_dm_datastore'
require 'test/unit'

class TestInlineCall
  extend Extlib::Hook::ClassMethods
end

class Person
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  
end

class Child < Person
  
  property :grade, String
end

class TestWeakReference < Test::Unit::TestCase
  
  def setup
    Extlib::Hook::ClassMethods.hook_scopes = []
  end
  
  def teardown
    Extlib::Hook::ClassMethods.hook_scopes = []
  end
  
  def test_add_object_to_hooks_scope

    scope_objects = [Person, Person.new]
    scope_objects.each {|object| Extlib::Hook::ClassMethods.hook_scopes << object }

    scope_objects.each {|object| assert Extlib::Hook::ClassMethods.hook_scopes.include? object}
    assert_equal scope_objects.count, Extlib::Hook::ClassMethods.hook_scopes.count
  end
  
  def test_inline_call
    assert_nothing_raised do
      eval TestInlineCall.inline_call({:from => Person, :name => 'person_class'},:instance)
    end
  end
  
  def test_find_object_by_id
    objects = [Person, Person.new, Child, Child.new]
    objects.each {|object| Extlib::Hook::ClassMethods.hook_scopes << object }
    
    assert_equal objects[0], Extlib::Hook::ClassMethods.object_by_id(objects[0].object_id)
    assert_equal objects[1], Extlib::Hook::ClassMethods.object_by_id(objects[1].object_id)
    assert_equal objects[3], Extlib::Hook::ClassMethods.object_by_id(objects[3].object_id)
    assert_equal objects[2], Extlib::Hook::ClassMethods.object_by_id(objects[2].object_id)

    assert_not_equal objects[2], Extlib::Hook::ClassMethods.object_by_id(objects[0].object_id)

    
  end
  
  def test_store_a_reference_for_ever_hooks_scope
    assert_nothing_raised do
      Extlib::Hook::ClassMethods.hook_scopes
    end
    #ExtLib::Hook::ClassMethods.responds_to? :hook_scopes
  end
  


  #test "the model should respond with a list of subclasses" do
    
  #end
  
end
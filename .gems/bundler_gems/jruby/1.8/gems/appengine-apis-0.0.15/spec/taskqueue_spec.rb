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
AppEngine::SDK.load_labs
require 'appengine-apis/labs/taskqueue'

TaskQueueAddRequest = JavaUtilities.get_proxy_or_package_under_package(
  com.google.appengine.api.labs.taskqueue,
  'TaskQueuePb$TaskQueueAddRequest'
)
TaskQueueAddResponse = JavaUtilities.get_proxy_or_package_under_package(
  com.google.appengine.api.labs.taskqueue,
  'TaskQueuePb$TaskQueueAddResponse'
)

describe AppEngine::Labs::TaskQueue do
  
  before :each do
    @delegate = mock_delegate
    AppEngine::ApiProxy.set_delegate(@delegate)
    @Queue = AppEngine::Labs::TaskQueue::Queue
    @Task = AppEngine::Labs::TaskQueue::Task
  end
  
  
  def expect_add(request, name = nil)
    response = TaskQueueAddResponse.new
    response.set_chosen_task_name(name) if name

    @delegate.should_receive(:makeSyncCall).with(
      anything, 'taskqueue', 'Add',
      proto(TaskQueueAddRequest, request)).and_return(response.to_byte_array)
  end
  
  describe AppEngine::Labs::TaskQueue::Queue do
    it 'should have name' do
      @Queue.new('foo').name.should == 'foo'
      @Queue.new('bar').name.should == 'bar'
    end
    
    it 'should have a default queue' do
      @Queue.new().name.should == 'default'
    end
  end
  
  describe AppEngine::Labs::TaskQueue::Task do
    before :each do
      @payload = 'this is the example payload'
      @binary_payload = "f\0\0bar"
      @params = {
             'one$funny&' => 'fish',
             'red' => 'blue with spaces',
             'fish' => ['guppy', 'flounder'],
          }
      @params_query = 'one%24funny%26=fish&fish=guppy&fish=flounder' +
                      '&red=blue+with+spaces'
    end
    
    it 'should set payload and method' do
      expect_add({:body => @payload, :method => 2})
      t = @Task.new(@payload).add
    end
    
    it 'should support Blob' do
      expect_add({:body => @binary_payload})
      t = @Task.new(AppEngine::Datastore::Blob.new(@binary_payload)).add
    end

    it 'should support bytes' do
      expect_add({:body => @binary_payload})
      t = @Task.new(:bytes => @binary_payload).add
    end

  end

  it 'should support add' do
    expect_add({:queue_name => 'default'}, 'foobar')
    now = Time.now
    t = AppEngine::Labs::TaskQueue.add
    t.name.should == 'foobar'
    t.queue.should == 'default'
    t.eta.should be >= now
  end

  it 'should support add with options' do
    expect_add({:body => 'payload', :method => 2, :queue_name => 'default'},
               'foobar')
    now = Time.now
    t = AppEngine::Labs::TaskQueue.add('payload')
    t.name.should == 'foobar'
    t.queue.should == 'default'
    t.eta.should be >= now
  end
  
  # TODO add more specs

end

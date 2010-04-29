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
require 'appengine-apis/xmpp'

module Proto
  %w(PresenceRequest PresenceResponse
     XmppInviteRequest XmppInviteResponse
     XmppMessageRequest XmppMessageResponse
     XmppServiceError).each do |name|
       const_set(name, JavaUtilities.get_proxy_or_package_under_package(
         com.google.appengine.api.xmpp, "XMPPServicePb$#{name}"
       ))
     end
end

  
# TODO test error handling
describe AppEngine::XMPP do
  
  before :each do
    @delegate = mock_delegate
    AppEngine::ApiProxy.set_delegate(@delegate)
  end

  def expect_presence(jid, available=true, from='')
    request = {
      :jid => jid,
      :from_jid => from
    }
    response = Proto::PresenceResponse.new
    response.set_is_available(available)
    
    @delegate.should_receive(:makeSyncCall).with(
      anything, 'xmpp', 'GetPresence', proto(Proto::PresenceRequest, request)
    ).and_return(response.to_byte_array)
  end

  def expect_invitation(jid, from='')
    request = {
      :jid => jid,
      :from_jid => from
    }
    @delegate.should_receive(:makeSyncCall).with(
      anything, 'xmpp', 'SendInvite', proto(Proto::XmppInviteRequest, request)
    ).and_return(Proto::XmppInviteResponse.new.to_byte_array)
  end

  def expect_send(request, *statuses)
    response = Proto::XmppMessageResponse.new
    statuses.each do |status|
      status = case status
      when :ok
        Proto::XmppMessageResponse::XmppMessageStatus::NO_ERROR.value
      when :invalid_jid
        Proto::XmppMessageResponse::XmppMessageStatus::INVALID_JID.value
      when :error
        Proto::XmppMessageResponse::XmppMessageStatus::OTHER_ERROR.value
      end
      response.add_status(status)
    end
    @delegate.should_receive(:makeSyncCall).with(
      anything, 'xmpp', 'SendMessage', proto(Proto::XmppMessageRequest, request)
    ).and_return(response.to_byte_array)
  end

  describe 'get_presence' do
    it 'should set jid' do
      expect_presence('foo@example.com')
      presence = AppEngine::XMPP.get_presence('foo@example.com')
      presence.should be_a_kind_of AppEngine::XMPP::Presence
      presence.available?.should == true
    end
    
    it 'should set sender' do
      expect_presence('foo@example.com', true, 'bar@appspot.com')
      presence = AppEngine::XMPP.get_presence(
          'foo@example.com', 'bar@appspot.com')
      presence.should be_a_kind_of AppEngine::XMPP::Presence
      presence.available?.should == true
    end
    
    it 'should set presence' do
      expect_presence('foo@example.com', false)
      presence = AppEngine::XMPP.get_presence(
          'foo@example.com')
      presence.should be_a_kind_of AppEngine::XMPP::Presence
      presence.available?.should == false
    end
  end

  describe 'send_invitation' do
    it 'should set jid' do
      expect_invitation('foo@example.com')
      AppEngine::XMPP.send_invitation('foo@example.com')
    end
    
    it 'should set sender' do
      expect_invitation('foo@example.com', 'bar@appspot.com')
      AppEngine::XMPP.send_invitation('foo@example.com', 'bar@appspot.com')
    end
  end

  describe 'send_message' do
    it 'should send message' do
      expect_send({:jid => ['foo@example.com'], :body => 'Hello!'}, :ok)
      status = AppEngine::XMPP.send_message('foo@example.com', 'Hello!')
      status.should == [AppEngine::XMPP::Status::NO_ERROR]
    end
    
    it 'should set status' do
      expect_send({:jid => ['a@example.com', 'b', 'c@foo.com']},
                  :ok, :invalid_jid, :error)
      status = AppEngine::XMPP.send_message(
          ['a@example.com', 'b', 'c@foo.com'], 'Hello!')
      status.should == [
        AppEngine::XMPP::Status::NO_ERROR,
        AppEngine::XMPP::Status::INVALID_JID,
        AppEngine::XMPP::Status::OTHER_ERROR
      ]
    end
  end

  describe AppEngine::XMPP::Message do
    describe 'initialize' do
      it 'should support minimal args' do
        message = AppEngine::XMPP::Message.new('foo@example.com', 'Hi')
        message.recipients.should == ['foo@example.com']
        message.body.should == 'Hi'
        message.sender.should == nil
        message.type.should == :chat
        message.xml?.should == false
      end
      
      it 'should require body' do
        no_to = lambda{AppEngine::XMPP::Message.new(nil, 'Hi')}
        no_body = lambda{AppEngine::XMPP::Message.new('foo@example.com')}
        no_to.should raise_error(ArgumentError)
        no_body.should raise_error(ArgumentError)
      end
      
      it 'should support positional args' do
        message = AppEngine::XMPP::Message.new(
          'foo@example.com', 'Hello, world!', 'test@appspot.com', :error,
          true)
        message.recipients.should == ['foo@example.com']
        message.sender.should == 'test@appspot.com'
        message.body.should == 'Hello, world!'
        message.type.should == :error
        message.xml?.should == true
      end
      
      it 'should support hash args' do
        message = AppEngine::XMPP::Message.new(
          :to =>'foo@example.com',
          :body => 'Hello, world!',
          :from => 'test@appspot.com',
          :type => :error,
          :xml => true)
        message.recipients.should == ['foo@example.com']
        message.sender.should == 'test@appspot.com'
        message.body.should == 'Hello, world!'
        message.type.should == :error
        message.xml?.should == true        
      end
      
      it 'should support combo args' do
        message = AppEngine::XMPP::Message.new(
          'foo@example.com', 'Hello, world!', :from => 'test@appspot.com')
        message.recipients.should == ['foo@example.com']
        message.body.should == 'Hello, world!'
        message.sender.should == 'test@appspot.com'
      end
    end
    
    describe 'command parsing' do
      it 'should set arg for non-command message' do
        message = AppEngine::XMPP::Message.new('a@example.com', 'Hello there')
        message.command.should == nil
        message.arg.should == 'Hello there'
      end
      
      it 'should parse slash commands' do
        message = AppEngine::XMPP::Message.new('a@example.com', '/test foo bar')
        message.command.should == 'test'
        message.arg.should == 'foo bar'
      end
      
      it 'should parse backslash commands' do
        message = AppEngine::XMPP::Message.new('a@example.com', '\test foo bar')
        message.command.should == 'test'
        message.arg.should == 'foo bar'
      end
    end
    
    describe 'reply' do
      it 'should send a reply' do
        expect_send({
          :jid => ['foo@example.com'],
          :body => 'Bye',
          :from_jid => 'test@appspot.com'
        }, :ok)
        message = AppEngine::XMPP::Message.new(
            'test@appspot.com', 'Hi', 'foo@example.com')
        message.reply('Bye')
      end
    end
  end

end

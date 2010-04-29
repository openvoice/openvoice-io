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
#
# XMPP API.

require 'appengine-apis/apiproxy'
require 'logger'

module AppEngine
  
  # The XMPP api provides an interface for accessing XMPP status information,
  # sending XMPP messages, and parsing XMPP responses.
  module XMPP
    module Proto
      %w(PresenceRequest PresenceResponse
         XmppInviteRequest XmppInviteResponse
         XmppMessageRequest XmppMessageResponse
         XmppServiceError).each do |name|
           const_set(name, JavaUtilities.get_proxy_or_package_under_package(
             com.google.appengine.api.xmpp, "XMPPServicePb$#{name}"
           ))
         end
      ErrorCode = XmppServiceError::ErrorCode
    end
    
    class XMPPError < StandardError; end

    module Status
      NO_ERROR = Proto::XmppMessageResponse::XmppMessageStatus::NO_ERROR.value
      INVALID_JID =
          Proto::XmppMessageResponse::XmppMessageStatus::INVALID_JID.value
      OTHER_ERROR =
          Proto::XmppMessageResponse::XmppMessageStatus::OTHER_ERROR.value
    end
    
    # Represents presence information returned by the server.
    class Presence
      def initialize(available)
        @available = available
      end
      
      def available?
        @available
      end
    end
    
    # Represents an incoming or outgoing XMPP Message.
    # Also includes support for parsing chat commands. Commands are of the form
    #   /{command} {arg}?
    # A backslash is also recognized as the first character to support chat
    # client which internally handle / commands.
    class Message      
      ARG_INDEX = {:to => 0, :body => 1, :from => 2, :type => 3, :xml => 4}
      COMMAND_REGEX = /^[\\\/](\S+)(\s+(.+))?/
      
      attr_reader :type, :sender, :recipients, :body
      
      # call-seq:
      #   Message.new(to, body, from=nil, type=:chat, xml=false)
      #   or
      #   Message.new(options)
      #
      # Constructor for sending an outgoing XMPP message or parsing
      # an incoming XMPP message.
      #
      # Args / Options:
      # [:to] Destination JID or array of JIDs for the message.
      # [:body] Body of the message.
      # [:from] 
      #     Optional custom sender JID. The default is <appid>@appspot.com.
      #     Custom JIDs can be of the form <anything>@<appid>.appspotchat.com.
      # [:type]
      #     Optional type. Valid types are :chat, :error, :groupchat,
      #     :headline, and :normal. See RFC 3921, section 2.1.1. The default
      #     is :chat.
      # [:xml]
      #     If true specifies that the body should be interpreted as XML.
      #     If false, the contents of the body will be escaped and placed
      #     inside of a body element inside of the message. If true, the
      #     contents will be made children of the message.
      def initialize(*args)
        if args.size == 1
          options = args[0]
        elsif args[-1].kind_of? Hash
          options = args.pop
        else
          options = {}
        end
        @recipients = fetch_arg(:to, options, args)
        @body = fetch_arg(:body, options, args)
        unless @recipients && @body
          raise ArgumentError, "Recipient and body are required."
        end
        @recipients = [@recipients] unless @recipients.kind_of? Array
        
        @sender = fetch_arg(:from, options, args)
        @type = fetch_arg(:type, options, args) || :chat
        @xml = !!fetch_arg(:xml, options, args)
      end
            
      def xml?
        @xml
      end
      
      # Returns the command if this message contains a chat command.
      def command
        parse_command
        @command
      end
      
      # If this message contains a chat command, returns the command argument.
      # Otherwise, returns the message body.
      def arg
        parse_command
        @arg
      end

      # Convenience method to reply to a message.
      def reply(body, type=:chat, xml=false)
        message = Message.new([sender], body, recipients[0], type, xml)
        XMPP.send_message(message)
      end

      private
      def parse_command
        return if @arg
        if body =~ COMMAND_REGEX
          @command = $1
          @arg = $3 || ''
        else
          @arg = body
        end
      end
      
      def to_proto
        proto = Proto::XmppMessageRequest.new
        recipients.each do |jid|
          proto.add_jid(jid)
        end
        proto.set_body(body)
        proto.set_raw_xml(xml?)
        proto.set_from_jid(sender) if sender
        proto.set_type(type.to_s)
        proto
      end
      
      def fetch_arg(name, options, args)
        arg = options[name] || args[ARG_INDEX[name]]
        unless arg.kind_of? String
          if arg.respond_to? :read
            arg = arg.read
          elsif arg.kind_of? Hash
            arg.each do |key, value|
              if value.respond_to? :read
                arg = value.read
                break
              end
            end
          end
        end
        arg
      end
    end
    
    class << self

      # Get the presence for a JID.
      #
      # Args:
      # - jid: The JID of the contact whose presence is requested.
      # - from_jid: Optional custom sender JID.
      #     The default is <appid>@appspot.com. Custom JIDs can be of the form
      #     <anything>@<appid>.appspotchat.com.
      #
      # Returns:
      # - A Presence object.
      def get_presence(jid, from_jid=nil)
        raise ArgumentError, 'Jabber ID cannot be nil' if jid.nil?
        request = Proto::PresenceRequest.new
        request.set_jid(jid)
        request.set_from_jid(from_jid) if from_jid
        
        response = make_sync_call('GetPresence', request,
                                  Proto::PresenceResponse)
        Presence.new(response.isIsAvailable)
      rescue ApiProxy::ApplicationException => ex
        case Proto::ErrorCode.value_of(ex.application_error)
        when Proto::ErrorCode::INVALID_JID
          raise ArgumentError, "Invalid jabber ID: #{jid}"
        else
          raise XMPPError, 'Unknown error retrieving presence for jabber ID: ' +
              jid
        end
      end
      
      # Send a chat invitaion.
      #
      # Args:
      # - jid: JID of the contact to invite.
      # - from_jid: Optional custom sender JID. 
      #     The default is <appid>@appspot.com. Custom JIDs can be of the form
      #     <anything>@<appid>.appspotchat.com.
      def send_invitation(jid, from_jid=nil)
        raise ArgumentError, 'Jabber ID cannot be nil' if jid.nil?
        request = Proto::XmppInviteRequest.new
        request.set_jid(jid)
        request.set_from_jid(from_jid) if from_jid

        make_sync_call('SendInvite', request, Proto::XmppInviteResponse)
        nil
      rescue ApiProxy::ApplicationException => ex
        case Proto::ErrorCode.value_of(ex.application_error)
        when Proto::ErrorCode::INVALID_JID
          raise ArgumentError, "Invalid jabber ID: #{jid}"
        else
          raise XMPPError, 'Unknown error sending invitation to jabber ID: ' +
              jid
        end
      end
      
      
      # call-seq:
      #   XMPP.send_message(message)
      #   or
      #   XMPP.send_message(*message_args)
      #
      # Send a chat message.
      #
      # Args:
      # - message: A Message object to send.
      # - message_args: Used to create a new Message. See #Message.new
      #
      # Returns an Array Statuses, one for each JID, corresponding to the
      # result of sending the message to that JID.
      def send_message(*args)
        if args[0].kind_of? Message
          message = args[0]
        else
          message = Message.new(*args)
        end
        request = message.send :to_proto
        response = make_sync_call('SendMessage', request,
                                  Proto::XmppMessageResponse)
        response.status_iterator.to_a
      rescue ApiProxy::ApplicationException => ex
        case Proto::ErrorCode.value_of(ex.application_error)
        when Proto::ErrorCode::INVALID_JID
          raise ArgumentError, "Invalid jabber ID"
        when Proto::ErrorCode::NO_BODY
          raise ArgumentError, "Missing message body"
        when Proto::ErrorCode::INVALID_XML
          raise ArgumentError, "Invalid XML body"
        when Proto::ErrorCode::INVALID_TYPE
          raise ArgumentError, "Invalid type #{message.type.inspect}"
        else
          raise XMPPError, 'Unknown error sending message'
        end
      end
      
      private
      def make_sync_call(call, request, response_class)
        bytes = ApiProxy.make_sync_call('xmpp', call, request.to_byte_array)
        response = response_class.new
        response.merge_from(bytes)
        return response
      end
    end
  end
end
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
#
# Ruby wrappers for the Java semantic data types for the datastore. These types
# are expected to be set as attributes of Entities.

require 'java'

class Time
  def to_java
    java.util.Date.new(tv_sec * 1000 + tv_usec / 1000.0)
  end

  def self.new_from_java(date)
    at(date.time / 1000.0)
  end
end

module AppEngine
  module Datastore
    JavaDatastore = Java.ComGoogleAppengineApiDatastore
    
    # Base class of Datastore Errors
    class Error < StandardError; end
    
    # Raised when a query requires a Composite index that does not exist
    class NeedIndex < Error; end
    
    # The datastore operation timed out. This can happen when you attempt to
    # put, get, or delete too many entities or an entity with too many
    # properties, or if the datastore is overloaded or having trouble.
    class Timeout < Error; end
    
    # An internal datastore error. Please report this to Google.
    class InternalError < Error; end
    
    # May be raised during a call to #transaction to abort and rollback the
    # transaction. Note that *any* exception raised by a transaction
    # block will cause a rollback. This is purely for convenience.
    class Rollback < Error; end
    
    # Raised when a transaction could not be committed, usually due to
    # contention.
    class TransactionFailed < Error; end
    
    # Raised by #get when the requested entity is not found.
    class EntityNotFound < Error; end
    
    # Raised by Datastore::Query.entity if the query returns more
    # than one entity
    class TooManyResults < Error; end
    
    # A long string type.
    # 
    # Strings of any length can be stored in the datastore using this
    # type.
    #
    # Not indexed.
    class Text < String
      def to_java
        JavaDatastore::Text.new(java.lang.String.new(self))
      end
      
      def self.new_from_java(text)
        self.new(text.getValue)
      end
    end
    
    # A blob type, appropriate for storing binary data of any length.
    # Not indexed.
    class Blob < String
      def to_java
        JavaDatastore::Blob.new(self.to_java_bytes)
      end
      
      def self.new_from_java(blob)
        self.new(self.from_java_bytes(blob.getBytes))
      end
    end
    
    # A byte-string type, appropriate for storing short amounts of indexed data.
    # 
    # This behaves identically to Blob, except it's used only for short, indexed
    # byte strings.
    #
    class ByteString < Blob
      def to_java
        JavaDatastore::ShortBlob.new(self.to_java_bytes)
      end
    end
    
    # A fully qualified URL. Usually http: scheme, but may also be file:, ftp:,
    # news:, among others.
    #
    class Link < String
      def to_java
        JavaDatastore::Link.new(java.lang.String.new(self))
      end
      
      def self.new_from_java(link)
        self.new(link.getValue)
      end
    end
    
    # An RFC2822 email address. Makes no attempt at validation.
    class Email < String
      def to_java
        JavaDatastore::Email.new(java.lang.String.new(self))
      end
      
      def self.new_from_java(email)
        self.new(email.getEmail)
      end      
    end

    # A tag, ie a descriptive word or phrase. Entities may be tagged by users,
    # and later returned by a queries for that tag. Tags can also be used for
    # ranking results (frequency), photo captions, clustering, activity, etc.
    #
    # More details:  http://www.zeldman.com/daily/0405d.shtml
    class Category < String
      def to_java
        JavaDatastore::Category.new(java.lang.String.new(self))
      end
      
      def self.new_from_java(category)
        self.new(category.getCategory)
      end
    end

    # A human-readable phone number.  No validation is performed because phone
    # numbers have many different formats - local, long distance, domestic,
    # international, internal extension, TTY, VOIP, SMS, and alternative
    # networks like Skype, XFire and Roger Wilco.  They all have their own
    # numbering and addressing formats.
    class PhoneNumber < String
      def to_java
        JavaDatastore::PhoneNumber.new(java.lang.String.new(self))
      end
      
      def self.new_from_java(phone)
        self.new(phone.getNumber)
      end
    end

    # A human-readable mailing address.  Mailing address formats vary widely so
    # no validation is performed.
    class PostalAddress < String
      def to_java
        JavaDatastore::PostalAddress.new(java.lang.String.new(self))
      end
      
      def self.new_from_java(address)
        self.new(address.getAddress)
      end
    end
    
    Rating = JavaDatastore::Rating

    # A user-provided integer rating for a piece of content. Normalized to a
    # 0-100 scale.
    class Rating
      # Raises ArgumentError if rating < 0 or rating > 100.
      def self.new(rating)
        if rating < MIN_VALUE || rating > MAX_VALUE
          raise ArgumentError, "rating must be no smaller than #{MIN_VALUE} " +
              "and no greater than #{MAX_VALUE} (received #{rating})"
        end
        super(rating)
      end
      
      alias to_i rating
      
      def to_s
        rating.to_s
      end
      
      def inspect
        "#<Rating #{rating}>"
      end
      
      if false
        MIN_VALUE = 0
        MAX_VALUE = 100
        def rating; end
      end
    end
    
    IMHandle = JavaDatastore::IMHandle

    # An instant messaging handle. Includes both an address and its protocol.
    # The protocol value is either a standard IM scheme (legal scheme values are
    # :sip, :xmpp, :unknown or a URL identifying the IM network for the
    # protocol (eg http://aim.com/).
    class IMHandle
      SCHEMES = {
        :sip => Scheme.sip,
        :xmpp => Scheme.xmpp,
        :unknown => Scheme.unknown
      }.freeze
      
      def self.new(protocol, address)
        begin
          protocol = SCHEMES[protocol] || java.net.URL.new(protocol)
        rescue java.net.MalformedURLException => ex
          raise ArgumentError, ex.message
        end
        super
      end
      
      if false
        def protocol; end
        def address; end
      end
    end
    
    GeoPt = JavaDatastore::GeoPt
    
    # A geographical point, specified by float latitude and longitude
    # coordinates. Often used to integrate with mapping sites like Google Maps.
    class GeoPt
      def self.new(latitude, longitude)
        super
      rescue java.lang.IllegalArgumentException => ex
        raise ArgumentError, ex.message
      end
      
      if false
        def latitude; end
        def longitude; end
      end
    end
    
    Key = JavaDatastore::Key
    
    # The primary key for a datastore entity.
    #
    # A datastore GUID. A Key instance uniquely identifies an entity
    # across all apps, and includes all information necessary to fetch
    # the entity from the datastore with #Datastore.get(Key).
    #
    # See also http://code.google.com/appengine/docs/java/javadoc/com/google/appengine/api/datastore/Key.html
    #
    class Key
      
      # Converts a Key into a websafe string.  For example, this string
      # can safely be used as an URL parameter embedded in a HTML document.
      #
      def to_s
        JavaDatastore::KeyFactory.keyToString(self)
      end
      
      alias :inspect :to_string
      alias :id :get_id
      alias :== :equals?
      
      def id_or_name
        name || id
      end
      
      class << self
        
        # Creates a new Key from an encoded String.
        def new(encoded)
          JavaDatastore::KeyFactory.stringToKey(encoded)
        end
        
        # call-seq:
        #   Key.from_path(parent=nil, kind, id, [kind, id]...) -> Key
        # Constructs a Key out of a path.
        #
        # This is useful when an application wants to use just the 'id'
        # portion of a key in e.g. a URL, where the rest of the URL
        # provides enough context to fill in the rest, i.e. the app id
        # (always implicit), the entity kind, and possibly an ancestor
        # key.  Since the 'id' is a relatively small int, it is more
        # attractive for use in end-user-visible URLs than the full
        # string representation of a key.
        #
        # Args:
        # - parent: Optional parent key
        # - kind: the entity kind (a string)
        # - id: the id (an integer)
        # - Additional, optional 'kind' and 'id' arguments are allowed in
        #  an alternating order (kind1, 1, kind2, 2, ...)
        # - options: a Hash. If specified, options[:parent] is used as
        #    the parent Key.
        #
        # Returns:
        # - A new Key instance whose #kind and #id methods return the *last*
        #    kind and id arugments passed
        #
        def from_path(parent_or_kind, kind_or_id, *args)
          # Extract parent
          parent = nil
          if parent_or_kind.is_a? Key
            parent = parent_or_kind
            args[0,0] = [kind_or_id]
          else
            args[0,0] = [parent_or_kind, kind_or_id]
          end

          if args.size % 2 != 0
            raise ArgumentError, 'Expected an even number of arguments ' \
                                 '(kind1, id1, kind2, id2, ...); received ' \
                                 "#{args.inspect}"
          end

          # Type-check parent
          if parent
            unless parent.is_a? Key
              raise ArgumentError, 'Expected nil or a Key as a parent; ' \
                                   "received #{parent} (a #{parent.class})."
            end
            unless parent.is_complete?
              raise KeyError, 'The parent key has not yet been Put.'
            end
          end

          current = parent
          (0...args.size).step(2) do |i|
            kind, id = args[i,2]
            kind = kind.to_s if kind.is_a? Symbol
            if current
              current = current.getChild(kind, id)
            else
              current = JavaDatastore::KeyFactory.createKey(kind, id)
            end
          end

          return current
        end
      end
    end
    
    KeyRange = JavaDatastore::KeyRange

    # Represents a range of unique datastore identifiers from
    # start.id to end.id inclusive. The Keys returned by an
    # instance of this class have been consumed in the datastore's
    # id-space and are guaranteed never to be reused.
    #
    # This class can be used to construct Entity Entities with
    # Keys that have specific id values without fear of the datastore
    # creating new records with those same ids at a later date.  This can be
    # helpful as part of a data migration or large bulk upload where you may
    # need to preserve existing ids and relationships between entities.
    class KeyRange
      include Enumerable
      
      if false
        # The first Key in the range.
        def start; end;
        
        # The last Key in the range.
        def end; end;
        
        # The size of the range.
        def size; end;
      end
      
      def each
        iterator.each do |key|
          yield key
        end
      end
    end
    
    Entity = JavaDatastore::Entity
    
    # Entity is the fundamental unit of data storage.  It has an
    # immutable identifier (contained in the Key) object, a
    # reference to an optional parent Entity, a kind (represented
    # as an arbitrary string), and a set of zero or more typed
    # properties.
    #
    # See also http://code.google.com/appengine/docs/java/javadoc/com/google/appengine/api/datastore/Entity.html
    #
    class Entity
      include Enumerable
      
      SPECIAL_JAVA_TYPES = {
        JavaDatastore::Text => Text,
        JavaDatastore::Blob => Blob,
        JavaDatastore::ShortBlob => ByteString,
        JavaDatastore::Link => Link,
        JavaDatastore::Email => Email,
        JavaDatastore::Category => Category,
        JavaDatastore::PhoneNumber => PhoneNumber,
        JavaDatastore::PostalAddress => PostalAddress,
        java.util.Date => Time,
      }.freeze
      
      alias :inspect :to_string
      alias :== :equals?
      
      if false
        # Create a new Entity with the specified kind and parent Entity.  The
        # instantiated Entity will have anincomplete Key when this constructor
        # returns. The Key will remain incomplete until you put the Entity,
        # after which time the Key will have its id set.
        def initialize(kind, parent=nil); end
        
        # Create a new Entity with the specified kind, key name, and parent
        # Entity. The instantiated Entity will have a complete Key when this
        # constructor returns. The Key's name field will be set to the value of
        # key_name.
        def initialize(kind, key_name, parent=nil); end
        
        # Create a new Entity uniquely identified by the provided Key.
        # Creating an entity for the purpose of insertion (as opposed
        # to update) with a key that has its id field set is strongly
        # discouraged unless the key was returned by a KeyRange.
        def initialize(key); end
      end
      
      # Returns the property with the specified name.
      def get_property(name)
        name = name.to_s if name.kind_of? Symbol
        prop = Datastore.convert_exceptions { getProperty(name) }
        java_value_to_ruby(prop)
      end
      alias :[] :get_property

      # Sets the property named, +name+, to +value+.
      # 
      # As the value is stored in the datastore, it is converted to the 
      # datastore's native type.  
      # 
      # All Enumerables are prone to losing their sort order and their
      # original types as they are stored in the datastore. For example, a
      # Set may be returned as an Array from #getProperty, with an
      # arbitrary re-ordering of elements. 
      #
      # +value+ may be one of the supported datatypes, or a heterogenous
      # Enumerable of one of the supported datatypes. 
      # 
      # Throws ArgumentError if the value is not of a type that
      # the data store supports.
      #
      def set_property(name, value)
        name = name.to_s if name.kind_of? Symbol
        value = Datastore.ruby_to_java(value)
        Datastore.convert_exceptions do
          setProperty(name, value)
        end
      end
      alias :[]= :set_property
      
      # Removes any property with the specified name.  If there is no
      # property with this name set, simply does nothing.
      #
      def delete(name)
        name = name.to_s if name.kind_of? Symbol
        Datastore.convert_exceptions do
          removeProperty(name)
        end
      end
      
      # Returns true if a property has been set. This function can
      # be used to test if a property has been specifically set
      # to nil.
      #
      def has_property?(name)
        name = name.to_s if name.kind_of? Symbol
        Datastore.convert_exceptions do
          hasProperty(name)
        end
      end
      alias :has_property :has_property?
      
      # Add the properties from +other+ to this Entity.
      # Other may be an Entity or Hash
      def update(other)
        other.each do |name, value|
          self[name] = value
        end
        self
      end
      alias merge! update
      
      # Iterates over all the properties in this Entity.
      def each()  # :yields: name, value
        getProperties.each do |name, value|
          yield name, java_value_to_ruby(value)
        end
      end
      
      def to_hash
        inject({}) do |hash, item|
          name, value = item
          hash[name] = value
          hash
        end
      end
      
      def java_value_to_ruby(prop)
        ruby_type = SPECIAL_JAVA_TYPES[prop.class]
        if ruby_type
          ruby_type.new_from_java(prop)
        else
          prop
        end
      end
    end
    
    SPECIAL_RUBY_TYPES = [Time, Text, Blob, ByteString, Link, Email,
                          Category, PhoneNumber, PostalAddress].freeze

    def Datastore.ruby_to_java(value)  # :nodoc:
      if SPECIAL_RUBY_TYPES.include? value.class
        value.to_java
      else
        case value
        when Fixnum
          java.lang.Long.new(value)
        when Float
          java.lang.Double.new(value)
        when String
          java.lang.String.new(value)
        else
          value
        end
      end
    end

    def Datastore.convert_exceptions  # :nodoc:
      begin
        yield
      rescue java.lang.IllegalArgumentException => ex
        raise ArgumentError, ex.message
      rescue java.lang.NullPointerException => ex
        raise ArgumentError, ex.message
      rescue java.util.ConcurrentModificationException => ex
        raise TransactionFailed, ex.message
      rescue java.util.NoSuchElementException => ex
        raise IndexError, ex.message
      rescue JavaDatastore::DatastoreNeedIndexException => ex
        raise NeedIndex, ex.message
      rescue JavaDatastore::DatastoreTimeoutException => ex
        raise Timeout, ex.message
      rescue JavaDatastore::DatastoreFailureException => ex
        raise InternalError, ex.message
      rescue JavaDatastore::EntityNotFoundException => ex
        raise EntityNotFound, ex.message
      rescue JavaDatastore::PreparedQuery::TooManyResultsException => ex
        raise TooManyResults, ex.message
      end
    end
  end
end
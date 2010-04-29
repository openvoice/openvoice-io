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
# Custom types for App Engine

require 'dm-core/type' unless defined? DataMapper::Type::PROPERTY_OPTIONS
require 'dm-core/property' unless defined? DataMapper::Property::PRIMITIVES

module DataMapper
  module Types
    class List < Type
      primitive ::Object

      def self.dump(value, property)
        value
      end
      
      def self.load(value, property)
        value.to_a if value
      end
      
      def self._type=(type)
        @type = type
      end
    end
    
    class AppEngineStringType < Type
      def self.dump(value, property)
        self::DATASTORE_TYPE.new(value) if value
      end
      
      def self.load(value, property)
        value
      end
    end
    
    class AppEngineNativeType < Type
      primitive ::Object
      
      def self.dump(value, property)
        value
      end
      
      def self.load(value, property)
        value
      end
    end
    
    class Blob < AppEngineStringType
      primitive String
      DATASTORE_TYPE = AppEngine::Datastore::Blob
      size 1024 * 1024
    end
    
    class ByteString < AppEngineStringType
      primitive String
      DATASTORE_TYPE = AppEngine::Datastore::ByteString
      size 500
    end
    
    class Link < AppEngineStringType
      primitive String
      DATASTORE_TYPE = AppEngine::Datastore::Link
      size 2038
    end
    
    class Email < AppEngineStringType
      primitive String
      DATASTORE_TYPE = AppEngine::Datastore::Email
      size 500
    end
    
    class Category < AppEngineStringType
      primitive String
      DATASTORE_TYPE = AppEngine::Datastore::Category
      size 500
    end
    
    class PhoneNumber < AppEngineStringType
      primitive String
      DATASTORE_TYPE = AppEngine::Datastore::PhoneNumber
      size 500
    end
    
    class PostalAddress < AppEngineStringType
      primitive String
      DATASTORE_TYPE = AppEngine::Datastore::PostalAddress
      size 500
    end
    
    class Rating < Type
      primitive ::Object
      
      def self.dump(value, property)
        AppEngine::Datastore::Rating.new(value) if value
      end
      
      def self.load(value, property)
        value.rating if value
      end
    end
    
    IMHandle = GeoPt = User = AppEngineNativeType
    
    class Key < Type
      primitive AppEngine::Datastore::Key
      
      def self.dump(value, property)
        property.typecast(value)
      end
      
      def self.load(value, property)
        value
      end
      
      def self.typecast(value, property)
        case value
        when AppEngine::Datastore::Key, NilClass
          value
        when Integer, String
          AppEngine::Datastore::Key.from_path(kind(property), value)
        when Symbol
          AppEngine::Datastore::Key.from_path(kind(property), value.to_s)
        when Hash
          parent = property.typecast(value[:parent])
          id = value[:id]
          name = value[:name]
          if id
            id_or_name = id.to_i
          elsif name
            id_or_name = name.to_s
          end
          if parent
            if id_or_name || (!property.key?)
              parent.getChild(kind(property), id_or_name)
            else
              # TODO: is it sane to not typecast this?
              value
            end
          else
            property.typecast(id_or_name)
          end
        else
          raise ArgumentError, "Unsupported key value #{value.inspect} (a #{value.class})"
        end
      end
      
      def self.kind(property)
        property.model.repository.adapter.kind(property.model)
      end
    end
    
    # Hacks for primitive types.
    # AppEngine::Datastore::Key truly IS a primitive,
    # as far as AppEngine is concerned.
    original_primitives = Property::PRIMITIVES
    Property::PRIMITIVES = (original_primitives.dup << AppEngine::Datastore::Key).freeze
    
    # Hack to allow a property defined as AppEngine::Datastore::Key to work.
    # This is needed for associations -- child_key tries to define it as
    # the primitive of the parent key type. It then takes that type name and
    # tries to resolve it in DM::Types, so we catch it here.
    module Java
      module ComGoogleAppengineApiDatastore
      end
    end
    Java::ComGoogleAppengineApiDatastore::Key = Key
    
    # Should NOT be used directly!
    # Also, should be sharing these better...
    class AncestorKey < Type
      primitive AppEngine::Datastore::Key
      def self.dump(value, property)
        property.typecast(value)
      end
      
      def self.load(value, property)
        value
      end
      
      def self.typecast(value, property)
        Key.typecast(value, property)
      end
    end
    
    # TODO store user as email and id?
  end
end

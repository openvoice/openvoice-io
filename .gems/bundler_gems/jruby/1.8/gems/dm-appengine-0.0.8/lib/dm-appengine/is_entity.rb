#!/usr/bin/ruby1.8 -w
#
# Copyright:: Copyright 2010 David Masover
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

module DataMapper
  module Is
    module Entity
      DEFAULT_ENTITY_OPTIONS = {
        :transaction => true,
        :key => :id,
        :parent => :parent,
        :ancestor => :ancestor,
        :descendants => :descendants
      }.freeze
      def is_entity(options={})
        extend(ClassMethods)
        
        options = DEFAULT_ENTITY_OPTIONS.merge(options)
        
        # Override the builtin transactions
        if options[:transaction]
          include Transaction; extend Transaction
        end
        
        # Pass :key_name => false if you don't want a key
        if (key_name = options[:key])
          primary_key(key_name)
        end
        
        if (parent_name = options[:parent])
          parent_property(parent_name)
        end
        
        if (ancestor_name = options[:ancestor])
          ancestor_property(ancestor_name)
        end
        
        if (descendants_name = options[:descendants])
          descendants_property(descendants_name)
        end
      end
      
      module ClassMethods
        # Being somewhat more rigid here, because this really isn't that complicated (yet).
        # TODO: If possible, a typeless query would be nice here.
        def descendants_property(name)
          define_method(name) do |type|
            type.all(:ancestor => self.key.first)
          end
        end
        
        def has_descendants(name, options={})
          model = options.delete(:model)  # or leave it nil
          define_method(name) do
            model ||= Extlib::Inflection.constantize(
              Extlib::Inflection.camelize(
                Extlib::Inflection.singularize(name.to_s)
              )
            )
            model.all(options.merge(:ancestor => self.key.first))
          end
        end
        
        def ancestor_property(name)
          property name, Types::AncestorKey
          # We don't want to ever set this. It's just for queries.
          undef_method name
          undef_method :"#{name}="
        end
        
        def primary_key(name)
          property name, DataMapper::Types::Key, :key => true
        end
        
        def parent_property(name)
          define_method("#{name}_id") do
            k = key.first
            k.kind_of?(AppEngine::Datastore::Key) && k.parent
          end
          
          belongs_to_entity(name, false)
        end
        
        # Polymorphic belongs_to hack.
        # (Datamapper doesn't support polymorphic associations, probably by design.)
        # We already have the type in the key_name anyway.
        # has(n) works at the other end, just set child_key.
        def belongs_to_entity(name, add_id_property=true)
          key_getter = :"#{name}_id"
          key_setter = :"#{key_getter}="
          variable = :"@#{name}"
          
          if add_id_property
            property key_getter, Types::Key
          end
          
          define_method(name) do
            value = instance_variable_get(variable)
            return value if value
            
            key = send(key_getter)
            # All keys are polymorphic
            value = Extlib::Inflection.constantize(Extlib::Inflection.singularize(key.kind)).get(key)
            instance_variable_set(variable, value)
          end
          
          define_method(:"#{name}=") do |value|
            send(key_setter, value.key.first)
            instance_variable_set(variable, value)
          end
        end
      end
      
      module Transaction
        def transaction(retries=3, &block)
          AppEngine::Datastore.transaction(retries, &block)
        end
      end
    end
  end
  
  Model.append_extensions(Is::Entity)
end
# Fix LocalObjectSpace hooks
module Extlib
  module Hook
    module ClassMethods
      extend LocalObjectSpace
      def inline_call(method_info, scope)
        Extlib::Hook::ClassMethods.hook_scopes << method_info[:from]
        name = method_info[:name]
        if scope == :instance
          args = method_defined?(name) && instance_method(name).arity != 0 ? '*args' : ''
          %(#{name}(#{args}) if self.class <= Extlib::Hook::ClassMethods.object_by_id(#{method_info[:from].object_id}))
        else
          args = respond_to?(name) && method(name).arity != 0 ? '*args' : ''
          %(#{name}(#{args}) if self <= Extlib::Hook::ClassMethods.object_by_id(#{method_info[:from].object_id}))
        end
      end
    end
  end
end

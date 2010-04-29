# Override Extlib::Hook::ClassMethods.inline_call
# to check in the given weak reference
module LocalObjectSpace
  def self.extended(klass)
    (class << klass; self;end).send :attr_accessor, :hook_scopes
    klass.hook_scopes = []
  end

  def object_by_id(object_id)
    self.hook_scopes.each do |object|
      return object if object.object_id == object_id
    end
  end
end

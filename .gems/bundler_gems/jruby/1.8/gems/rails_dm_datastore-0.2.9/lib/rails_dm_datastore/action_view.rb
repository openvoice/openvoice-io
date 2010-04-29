# makes the shorthand <%= render @posts %> work
# for collections of DataMapper objects
module ActionView
  module Partials
  alias :render_partial_orig :render_partial
  private
    def render_partial(options = {})
      if DataMapper::Collection === options[:partial]
        collection = options[:partial]
        options[:partial] = options[:partial].first.class.to_s.tableize.singular
        render_partial_collection(options.merge(:collection => collection))
      else
        render_partial_orig(options)
      end
    end
  end
end

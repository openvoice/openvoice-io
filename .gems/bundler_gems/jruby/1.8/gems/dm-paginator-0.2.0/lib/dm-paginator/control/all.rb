module DataMapper
  module Paginator
    module ControlHelper
      class All
        include DataMapper::Paginator::ControlHelperAbstract

        attr_reader :paginator, :options

        def initialize paginator, options = {}
          if !paginator.is_a?( Main )
            raise ArgumentError, "paginator argument is not an instance of Main"
          end

          @paginator = paginator
          @options = options
        end

        def pages page_range = nil
          return unless paginator.page_count > 0
          return pages_in_range 1, paginator.count
        end
      end
    end
  end
end
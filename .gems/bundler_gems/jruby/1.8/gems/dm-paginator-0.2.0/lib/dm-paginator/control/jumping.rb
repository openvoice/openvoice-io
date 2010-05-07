module DataMapper
  module Paginator
    module ControlHelper
      class Jumping
        include DataMapper::Paginator::ControlHelperAbstract

        attr_reader :paginator, :options

        def initialize paginator, options = {}
          if !paginator.is_a?( Main )
            raise ArgumentError, "paginator argument is not an instance of Main"
          end

          @paginator = paginator
          @options = options
          @options[:page_range] = options[:page_range].to_i || DataMapper::Paginator::default[:page_range]
        end

        def pages page_range = nil
          return unless paginator.page_count > 0

          page_range = options[:page_range] || page_range
          page_number = paginator.page

          delta = page_number % page_range

          if delta == 0
            delta = page_range
          end

          offset = page_number - delta
          lower = offset + 1
          upper = offset + page_range

          return pages_in_range lower, upper
        end
      end
    end
  end
end
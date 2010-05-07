module DataMapper
  module Paginator
    module ControlHelper
      class Elastic < Sliding
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
          page_number = normalize_page_number paginator.page
          original_page_range = page_range
          page_range = page_range * 2 - 1

          if original_page_range + page_number - 1 < page_range
            page_range = original_page_range + page_number -1
          elsif original_page_range + page_number - 1 > paginator.count
            page_range = original_page_range + paginator.count - page_number
          end

          return super( page_range )
        end
      end
    end
  end
end

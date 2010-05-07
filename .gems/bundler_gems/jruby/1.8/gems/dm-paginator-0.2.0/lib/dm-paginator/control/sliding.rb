module DataMapper
  module Paginator
    module ControlHelper
      class Sliding
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

          if page_range > paginator.count
            page_range = paginator.count
          end

          delta = ( page_range / 2 ).ceil

          if paginator.page - delta > paginator.count - page_range
            lower = paginator.count - page_range + 1
            upper = paginator.count
          else
            if paginator.page - delta < 0
              delta = paginator.page
            end

            offset = paginator.page - delta
            lower = offeset + 1
            upper = offset + page_range
          end

          return pages_in_range lower, upper
        end
      end
    end
  end
end
module DataMapper
  module Paginator
    module ControlHelperAbstract      
      ##
      # Get pages using a pagination style.
      #
      def pages page_range = nil
        raise NotImplementedError, "draw method not implemented"
      end

      ##
      # Return pages in range.
      #
      # @param [Integer] lower
      # @param [Integer] upper
      # @return [Array]
      def pages_in_range lower, upper
        lower = normalize_page_number lower
        upper = normalize_page_number upper

        pages = []
        ( lower ).upto( upper ) do | page_number |
          pages.push( page_number )
        end

        pages
      end

      ##
      # Normalize page number, brings the page number in range of the
      # paginator.
      #
      # @param [Integer] page_number
      # @return [Integer]
      def normalize_page_number page_number
        if page_number.to_i < 1
          page_number = 1
        end

        if paginator.count > 0 && page_number > paginator.count
          page_number = paginator.count
        end

        page_number.to_i
      end
    end
  end
end

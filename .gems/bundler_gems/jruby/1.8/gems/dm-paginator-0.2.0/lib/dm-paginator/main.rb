module DataMapper
  module Paginator
    ##
    # Main class, this object handle pagination attributes.
    #
    class Main
      attr_reader :count, :page, :limit, :offset, :page_count, :next_page,
        :previous_page

      def initialize options = {}
        @count = options[:count].to_i
        @page = options[:page].to_i
        @limit = options[:limit].to_i
        @offset = options[:offset].to_i
        @page_count = calculate_page_count
        @next_page = page.to_i + 1 unless page.to_i + 1 >= page_count
        @previous_page = page.to_i - 1 unless page.to_i - 1 <= 1
      end

      ##
      # Draw pagination controls using a partial (whatever erb file).
      #
      # @param [String] kind
      # @param [String] erb
      # @param [Hash] options
      # @return [String]
      def to_html kind, erb, options = {}
        if !File.file?( erb )
          raise IOError, "erb files doesn't exists"
        end

        template = ERB.new File.read( erb ), 0, "%<>"

        control = DataMapper::Paginator::Control.factory self, kind.to_s, options
        @pages = control.pages
        template.result binding
      end

      ##
      # Get pages range using a pagination control style.
      #
      # @param [String] kind
      #
      def pages kind, options = {}
        control = DataMapper::Paginator::Control.factory self, kind.to_s, options
        control.pages
      end

      private

      ##
      # Calculate how many page.
      #
      # @return [Integer]
      def calculate_page_count
        @page_count = count.to_i / limit.to_i
        @page_count.ceil
      end
    end
  end
end
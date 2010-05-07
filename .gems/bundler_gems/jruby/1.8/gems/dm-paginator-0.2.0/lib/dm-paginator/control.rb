module DataMapper
  module Paginator
    class Control
      class << self; protected :new; end

      ##
      # Factory.
      #
      # @param [Main] paginator
      # @param [String] kind
      # @param [Hash] options
      # @return [Sliding|Elastic|Jumping|All]
      def self.factory paginator, kind = nil, options = {}
        if !paginator.is_a?( Main )
          raise ArgumentError, "paginator argument is not an instance of Main"
        end
        
        case kind.downcase!
          when "sliding"
            return DataMapper::Paginator::ControlHelper::Sliding.new paginator, options
          when "elastic"
            return DataMapper::Paginator::ControlHelper::Elastic.new paginator, options
          when "jumping"
            return DataMapper::Paginator::ControlHelper::Jumping.new paginator, options
          when "all", kind.empty?
            return DataMapper::Paginator::ControlHelper::All.new paginator, options
        end
      end
    end
  end
end
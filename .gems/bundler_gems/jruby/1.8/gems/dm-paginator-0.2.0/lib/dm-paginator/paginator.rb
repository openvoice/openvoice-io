module DataMapper
  module Paginator
    attr_accessor :paginator
    
    ##
    # Limit results.
    #
    # @param [Hash] options
    # @return [Collection]
    def limit options = {}
      # Remove this key if we come from limit_page method.
      page = options.delete :page
      query = options.dup
      collection = new_collection scoped_query( options = {
        :limit => options[:limit],
        :offset => options[:offset],
        :order => [options[:order]]
      }.merge( query ) )
      options.merge! :count => calculate_total_records( query ), :page => page
      collection.paginator = DataMapper::Paginator::Main.new options
      collection
    end

    ##
    # Limit results by page.
    #
    # @param [Integer, Hash] page
    # @param [Hash] options
    # @return [Collection]
    def limit_page page = nil, options = {}
      if page.is_a?( Hash )
        options = page
      else
        options[:page] = page.to_i
      end

      options[:page] = options[:page].to_i > 0 ? options[:page] : DataMapper::Paginator.default[:page]
      options[:limit] = options[:limit].to_i || DataMapper::Paginator.default[:limit]
      options[:offset] = options[:limit] * ( options[:page] - 1 )
      options[:order] = options[:order] || DataMapper::Paginator.default[:order]
      limit options
    end

    private

    ##
    # Calculate total records
    #
    # @param [Hash] query
    # @return [Integer]
    def calculate_total_records query
      # Remove those keys from the query
      query.delete :page
      query.delete :limit
      query.delete :offset
      collection = new_collection scoped_query( query )
      collection.count.to_i
    end
  end
end

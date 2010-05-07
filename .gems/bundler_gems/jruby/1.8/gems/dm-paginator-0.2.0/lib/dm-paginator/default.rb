module DataMapper
  module Paginator
    @default = {
      :page => 1,
      :limit => 10,
      :order => :id.desc,
      :page_range => 10,
    }

    def self.default
      @default
    end
  end
end

# set a nil date or time when a date cannot be parced
# to avoid exception by ruby via to_date and to_time
module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module String #:nodoc:
      # Converting strings to other objects
      module Conversions
        # 'a'.ord == 'a'[0] for Ruby 1.9 forward compatibility.
        def ord
          self[0]
        end if RUBY_VERSION < '1.9'
        # Form can be either :utc (default) or :local.
        def to_time(form = :utc)
          begin
            ::Time.send("#{form}_time", *::Date._parse(self, false).
                values_at(:year, :mon, :mday, :hour, :min, :sec).
                map { |arg| arg || 0 })
          rescue
            nil
          end
        end
        def to_date
          begin
            ::Date.new(*::Date._parse(self, false).
                values_at(:year, :mon, :mday))
          rescue
            nil
          end
        end
        def to_datetime
          begin
            ::DateTime.civil(*::Date._parse(self, false).
                values_at(:year, :mon, :mday, :hour, :min, :sec).
                map { |arg| arg || 0 })
          rescue
            nil
          end
        end
      end
    end
  end
end

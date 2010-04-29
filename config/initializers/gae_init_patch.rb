require "rails/backtrace_cleaner.rb"
module Rails
  class BacktraceCleaner < ActiveSupport::BacktraceCleaner
    def add_gem_filters
      add_filter { |line| line.sub(/(.+gems\.jar\!\/)(.*)/, '\2')}
    end
  end
end

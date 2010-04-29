module Rails
  class << self
    def pick_boot
      BundlerBoot.new
    end
  end
  class BundlerBoot < Boot
    def load_initializer
      eval <<-END, TOPLEVEL_BINDING, __FILE__, __LINE__
        require "thread"
        class Gem::Dependency
        end
        require 'initializer'
        # require "#{RAILS_ROOT}/.gems/bundler_gems/gems/rails-2.3.5/lib/initializer"
        module Rails
          class Initializer
            def add_gem_load_paths
              puts "SKIP: add_gem_load_paths" if ENV['VERBOSE']
            end
          end
        end
        #module Gem
        #  remove_const :Dependency
        #end
        module Rails
          remove_const :GemDependency
          class GemDependency
            class << self
              def method_missing(m, *args)
                puts "Rails::GemDependency.\#{m}(\#{args.inspect}) is called." if ENV['VERBOSE']
              end
            end
          end
        end

        # initializer.rb: Dir["\#{RAILTIES_PATH}/builtin/*/"] is not work in jruby 1.4.0. jruby bug???
        class Rails::Configuration
          def builtin_directories
            return [] unless environment == 'development'
            Dir["\#{File.expand_path(RAILTIES_PATH)}/builtin/*"].select{|d| File.directory?(d) }
          end
        end

        # template.rb: `Dir.glob("#{@path}/**/*/**")` is not work in jruby 1.4.0. jruby bug???
        require "action_view"
        class ActionView::Template::EagerPath
          def templates_in_path
            Dir.glob("\#{@path}/**/*").each do |file|
              yield create_template(file) unless File.directory?(file)
            end
          end
        end
      END
      #Rails::GemDependency.hello(:world, 1234)
    end
  end
end

if ENV["RAILS_ENV"]=="development"
  class Dir
    class << self
      alias_method :__glob_orig, :glob
      def glob(*args, &block)
        ret = __glob_orig(*args, &block)
        p ["Dir.glob", args, ret] if ret.empty? and ENV['VERBOSE']
        ret
      end
      alias_method :__glob2_orig, :"[]"
      def [](*args, &block)
        ret = __glob2_orig(*args, &block)
        p ["Dir.glob2", args, ret] if ret.empty? and ENV['VERBOSE']
        ret
      end
    end
  end
end

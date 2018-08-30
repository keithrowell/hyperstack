require 'opal'
require 'hyper-store'
require 'hyper-component'
require 'hyper-transport'

if RUBY_ENGINE == 'opal'
  require 'promise'
  require 'native'
  require 'hyperstack/props_wrapper'
  require 'hyperstack/params/instance_methods'
  require 'hyperstack/params/class_methods'
  require 'hyperstack/validator'
  require 'hyperstack/operation/class_methods'
  require 'hyperstack/operation/mixin'
  require 'hyperstack/operation'
else
  require 'oj'
  require 'hyperstack/promise'
  require 'hyperstack/props_wrapper'
  require 'hyperstack/params/instance_methods'
  require 'hyperstack/params/class_methods'
  require 'hyperstack/validator'
  require 'hyperstack/operation/class_methods'
  require 'hyperstack/operation/mixin'
  require 'hyperstack/operation'
  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)
  if Dir.exist?(File.join('app', 'hyperstack', 'operations'))
    # Opal.append_path(File.expand_path(File.join('app', 'hyperstack', 'operations'))) <- opal-autoloader will handle this
    Opal.append_path(File.expand_path(File.join('app', 'hyperstack'))) unless Opal.paths.include?(File.expand_path(File.join('app', 'hyperstack')))
  elsif Dir.exist?(File.join('hyperstack', 'operations'))
    # Opal.append_path(File.expand_path(File.join('hyperstack', 'models', 'operations'))) <- opal-autoloader will handle this
    Opal.append_path(File.expand_path(File.join('hyperstack'))) unless Opal.paths.include?(File.expand_path(File.join('hyperstack')))
  end

  # special treatment for rails
  if defined?(Rails)
    module Hyperstack
      class Operation
        class Railtie < Rails::Railtie
          def delete_first(a, e)
            a.delete_at(a.index(e) || a.length)
          end

          config.before_configuration do |_|
            Rails.configuration.tap do |config|
              config.eager_load_paths += %W(#{config.root}/app/hyperstack/handlers)
              config.eager_load_paths += %W(#{config.root}/app/hyperstack/operations)
              # rails will add everything immediately below app to eager and auto load, so we need to remove it
              delete_first config.eager_load_paths, "#{config.root}/app/hyperstack"

              unless Rails.env.production?
                config.autoload_paths += %W(#{config.root}/app/hyperstack/handlers)
                config.autoload_paths += %W(#{config.root}/app/hyperstack/operations)
                # rails will add everything immediately below app to eager and auto load, so we need to remove it
                delete_first config.autoload_paths, "#{config.root}/app/hyperstack"
              end
            end
          end
        end
      end
    end
  elsif Dir.exist?(File.join('app', 'hyperstack'))
    # TODO unless
    $LOAD_PATH.unshift(File.expand_path(File.join('app', 'hyperstack', 'handlers')))
    $LOAD_PATH.unshift(File.expand_path(File.join('app', 'hyperstack', 'operations')))
  elsif Dir.exist?(File.join('hyperstack'))
    $LOAD_PATH.unshift(File.expand_path(File.join('hyperstack', 'handlers')))
    $LOAD_PATH.unshift(File.expand_path(File.join('hyperstack', 'operations')))
  end
end
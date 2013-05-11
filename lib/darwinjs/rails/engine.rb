require 'coffee/rails/engine'

module Darwinjs
  module Rails
    class Engine < ::Rails::Engine
      config.app_generators.javascript_engine :darwinjs
    end
  end
end

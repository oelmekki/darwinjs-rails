require "rails/generators/named_base"

module Darwinjs
  module Generators
    class AssetsGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      def create_module
        if is_resource?
          ResourceGenerator.new( name, self ).process
        else
          ActionGenerator.new( name, self ).process
        end
      end

      private

      def is_resource?
        name.underscore != name
      end

      class JsModuleGenerator
        attr_reader :name, :base_generator

        def initialize( name, base_generator )
          @name, @base_generator = name, base_generator
        end

        def method_missing( method_name, *args, &block )
          base_generator.send( method_name, *args, &block )
        end
      end

      class ResourceGenerator < JsModuleGenerator
        def process
          %w[index edit show new form].each do |action|
            ActionGenerator.new( "#{name.pluralize.underscore}/#{action}", base_generator ).process
          end
        end
      end

      class ActionGenerator < JsModuleGenerator
        def process
          create_namespaces
          create_controller
          create_view
        end

        private

        def create_namespaces
          current_path = []

          namespaces.each do |namespace|
            current_path << namespace
            namespace_dir  = current_path.join( '/' )
            namespace_file = namespace_dir + '.coffee'
            @namespace = current_path.map( &:camelize ).join( '.' )

            unless File.exists?( controllers_path.join( namespace_file ) )
              template 'controllers/namespace.coffee', controllers_path.join( namespace_file ).to_s
            end

            unless File.exists?( views_path.join( namespace_file ) )
              template 'views/namespace.coffee', views_path.join( namespace_file ).to_s
            end
          end
        end

        def create_controller
          @js_path = name.split( '/' ).map( &:camelize ).join( '.' )
          template 'controllers/controller.coffee', controllers_path.join( "#{name}.coffee" )
        end

        def create_view
          @js_path = name.split( '/' ).map( &:camelize ).join( '.' )
          template 'views/view.coffee', views_path.join( "#{name}.coffee" )
        end

        def namespaces
          @namespaces ||= begin
            parts = name.split( '/' )
            parts.pop
            parts
          end
        end

        def controllers_path
          @controllers_path ||= ::Rails.root.join( 'app', 'assets', 'javascripts', 'controllers' )
        end

        def views_path
          @views_path ||= ::Rails.root.join( 'app', 'assets', 'javascripts', 'views' )
        end
      end
    end
  end
end

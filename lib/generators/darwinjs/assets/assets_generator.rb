require "rails/generators/named_base"

module Darwinjs
  module Generators
    class AssetsGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      def create_module
        if is_resource?
          create_resource
        else
          create_action( ( class_path + [ file_name ] ).join( '/' ) )
        end
      end

      private

      def is_resource?
        name.underscore != name
      end

      def create_resource
        %w[index edit show new form].each do |action|
          create_action( ( class_path + [ file_name.pluralize, action ] ).join( '/' ) )
        end
      end

      def create_action( action )
        create_namespaces( action )
        create_controller( action )
        create_view( action )
      end

      def create_namespaces( action )
        current_path = []

        namespaces_for( action ).each do |namespace|
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

      def create_controller( action )
        @js_path = action.split( '/' ).map( &:camelize ).join( '.' )
        template 'controllers/controller.coffee', controllers_path.join( "#{action}.coffee" )
      end

      def create_view( action )
        @js_path = action.split( '/' ).map( &:camelize ).join( '.' )
        template 'views/view.coffee', views_path.join( "#{action}.coffee" )
      end

      def namespaces_for( action )
        parts = action.split( '/' )
        parts.pop
        parts
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

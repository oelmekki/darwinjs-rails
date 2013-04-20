class DarwinGenerator < Rails::Generators::NamedBase
  def create_module
    create_namespaces
    create_controller
    create_view
  end

  private

  def namespaces
    @namespaces ||= begin
      parts = name.split( '/' )
      parts.pop
      parts
    end
  end

  def create_namespaces
    current_path = []

    namespaces.each do |namespace|
      current_path << namespace
      namespace_dir  = current_path.join( '/' )
      namespace_file = namespace_dir + '.coffee'

      unless File.exists?( controllers_path.join( namespace_file ) )
        create_file controllers_path.join( namespace_file ).to_s, <<-EOS
App.Controllers.#{current_path.map( &:camelize ).join( '.' )} = {}
        EOS
      end

      unless File.exists?( views_path.join( namespace_file ) )
        create_file views_path.join( namespace_file ).to_s, <<-EOS
App.Views.#{current_path.map( &:camelize ).join( '.' )} = {}
        EOS
      end
    end
  end

  def create_controller
    js_path = name.split( '/' ).map( &:camelize ).join( '.' )

    create_file controllers_path.join( "#{name}.coffee" ), <<-EOS
class App.Controllers.#{js_path} extends Darwin.Controller
  @options {
    View: App.Views.#{js_path}
    events: {}
  }
    EOS
  end

  def create_view
    js_path = name.split( '/' ).map( &:camelize ).join( '.' )

    create_file views_path.join( "#{name}.coffee" ), <<-EOS
class App.Views.#{js_path} extends Darwin.View
  @options {
    selectors: {}
  }
    EOS
  end

  def controllers_path
    @controllers_path ||= Rails.root.join( 'app', 'assets', 'javascripts', 'controllers' )
  end

  def views_path
    @views_path ||= Rails.root.join( 'app', 'assets', 'javascripts', 'views' )
  end
end

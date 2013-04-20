#= require './base'

class Darwin.Template extends Darwin.Base
  @_cached: {}
  
  @options {
    dependencies:
      Mustache: window.Mustache
  }

  constructor: ( @template ) ->
    super

    @retrieve_template_from_dom() unless @retrieve_template_from_memory()


  retrieve_template_from_memory: ->
    if Templates?[ @template ]
      @template = Templates[ @template ]
      true
    else
      false

  retrieve_template_from_dom: ->
    name = @template.replace( '#', '' )

    if Darwin.Template._cached[ name ]
      @template = Darwin.Template._cached[ name ]
    else
      $template = $( "script##{name}_template[type=\"text/mustache\"]" )

      unless $template.length
        throw new Error( "can't find template #{name}" )

      @template = $template.html()
      Darwin.Template._cached[ name ] = @template


  render: ( data ) ->
    $( @render_to_string(data ) )
    
  render_to_string: (data) ->
    Mustache.render( @template, data )

# Documentation is in /doc/base.md
#
reserved_keywords = [ 'extended', 'included' ]

class Darwin.Base
  @options: ( options ) ->
    parent_options = @__super__.constructor._options

    if parent_options?
      @_options = $.extend true, {}, parent_options, options
    else
      @_options = options


  @extend: ( obj ) ->
    for key, value of obj when key not in reserved_keywords
      @[ key ] = value

    obj.extended?.apply(@)
    @


  @include: ( obj ) ->
    for key, value of obj when key not in reserved_keywords
      @::[ key ] = value

    obj.included?.apply(@)
    @


  constructor: ( options ) ->
    @_bound = {}

    @options = $.extend( {}, @constructor._options, options )

    if @options.dependencies?
      for own name, dependency of @options.dependencies
        @[ name ] = dependency


  bind: ( event_name, callback ) ->
    @_bound[ event_name ] ?= []
    @_bound[ event_name ].push( callback )


  on: ( event_name, callback ) ->
    @bind( event_name, callback )


  one: ( event_name, callback ) ->
    callback = =>
      @unbind event_name, callback

    @bind event_name, callback


  unbind: ( event_name, callback ) ->
    if @_bound[ event_name ]
      if callback
        $.each @_bound[ event_name ], ( i, bound ) ->
          if bound == callback
            delete @_bound[ event_name ][ i ]

      else
        delete @_bound[ event_name ]


  unbind_all: ->
    @_bound = {}


  trigger: ( event_name, params... ) ->
    if @_bound[ event_name ]
      for callback in @_bound[ event_name ]
        callback( params... )

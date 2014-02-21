# Documentation is in /doc/controller.md
#
class Darwin.Controller extends Darwin.Base
  @options {
    events: {}
    View: Darwin.View
    failsafe: true
  }


  constructor: ( root, options ) ->
    super options

    @root = root.get(0)

    if @root
      @_dom_bound = []
      @$root      = $( @root )
      @view       = new @options.View @$root

      @bind_events() unless exports?
      @view.run()
      @run() unless exports?
    else
      throw new Error( 'Controller initialized without any element' )


  run: ->


  bind_events: ->
    @bind_event( event, name ) for own name, event of @options.events


  bind_event: ( definition, name ) ->
    unless definition.el?
      throw new Error( "No el key for event : #{name or 'manually bound event'}" )

    unless definition.type?
      throw new Error( "No type key for event : #{name or 'manually bound event'}" )

    [ method, method_name ] = @_find_method( definition )

    if definition.el is 'darwin'
      @bind_global_event( definition, method, method_name )
    else
      @bind_dom_event( definition, method, method_name )


  bind_global_event: ( definition, method, method_name ) ->
    Darwin.on( definition.type, =>
      unless window.crashed and @options.failsafe is true
        method( arguments... )
    )


  bind_dom_event: ( definition, method, method_name ) ->
    wrap = @_wrap_for_dom_element
    definition.stop = true if definition.type == 'click' and ! definition.stop?
    $element = @view.get( definition.el )

    if definition.delegate
      delegate_to = @view.selectors[ definition.delegate ] or @view._find_alternate_name( definition.delegate )

      if definition.cancel_delay and definition.cancel_delay > 0
        callback = ( event ) =>
          window.clearTimeout $element.data( "_#{method_name}_timeout" )
          wrapped = wrap( method, definition )
          $element.data( "_#{method_name}_timeout", window.setTimeout( ( -> ( wrapped event ) ), definition.cancel_delay ) )
      else
        callback = wrap method, definition

      throw new Error "Selector not found : #{definition.delegate}" unless delegate_to
      $element.delegate delegate_to.sel, definition.type, callback
      @_dom_bound.push { el: $element, delegate: delegate_to.sel, type: definition.type, callback: callback }
    else
      if definition.cancel_delay and definition.cancel_delay > 0
        callback = ( event ) =>
          window.clearTimeout $element.data( "_#{method_name}_timeout" )
          wrapped = wrap( method, definition )
          $element.data( "_#{method_name}_timeout", window.setTimeout( ( -> ( wrapped event ) ), definition.cancel_delay ) )
      else
        callback = wrap method, definition

      $element.bind definition.type, callback
      @_dom_bound.push { el: $element, type: definition.type, callback: callback }


  _wrap_for_dom_element: ( callback, definition ) =>
    ( event ) =>
      unless window.crashed and @options.failsafe is true
        event.preventDefault() if definition.stop
        $target = $( event.target )

        if definition.ensure_element isnt false
          el = if definition.delegate? then definition.delegate else definition.el
          
          if el == 'root'
            sel = 'root'
          else
            sel = ( @view.selectors[ el ] or @view._find_alternate_name( el ) )?.sel

            if sel
              $target = $target.parents( sel ).first() unless $target.is( sel )
            else
              $target = @view.get( el )

        args = [ $target, event ]
        args.push arguments[i] for i in [1..(arguments.length - 1)] if arguments.length > 1

        callback( args... )


  _find_method: ( definition ) ->
    switch true
      when !! definition.controller_method
        method_name = definition.controller_method
        if @[ method_name ]
          method = $.proxy( @[ method_name ], this )
        else
          throw new Error( "Undefined method for controller : #{method_name}" )

      when !! definition.view_method
        method_name = definition.view_method
        if @view[ method_name ]
          method = $.proxy( @view[ method_name ], @view )
        else
          throw new Error( "Undefined method for view : #{method_name}" )

      else
        method_name = "#{definition.delegate or definition.el}_#{definition.type}#{if definition.type.match( /e$/ ) then 'd' else 'ed' }"
        if @[ method_name ]
          method = $.proxy( @[ method_name ], this )
        else
          throw new Error( "Undefined method for controller : #{method_name}" )

    [ method, method_name ]


  destructor: ->
    @view._destructor()
    for bound in @_dom_bound
      if bound.delegate
        bound.el.undelegate bound.delegate, bound.type, bound.callback
      else
        bound.el.unbind bound.type, bound.callback

    delete Darwin.Loader.controllers()[ @id ]



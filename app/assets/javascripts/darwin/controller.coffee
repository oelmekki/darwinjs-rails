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

      @bind_dom_events() unless exports?
      @view.run()
      @run() unless exports?
    else
      throw new Error( 'Controller initialized without any element' )


  run: ->


  bind_dom_events: ->
    @bind_dom_event( event, name ) for own name, event of @options.events


  bind_dom_event: ( definition, name ) ->
    unless definition.el?
      throw new Error( "No el key for event : #{name or 'manually bound event'}" )

    unless definition.type?
      throw new Error( "No type key for event : #{name or 'manually bound event'}" )


    wrap = ( callback, stop ) =>
      ( event ) =>
        unless ( window.crashed and @options.failsafe is true )
          event.preventDefault() if stop
          $target = $( event.target )

          if definition.ensure_element isnt false
            el = if definition.delegate? then definition.delegate else definition.el
            
            if el == 'root'
              sel = 'root'
            else
              sel = ( @view.selectors[ el ] or @view._find_alternate_name( el ) ).sel

            $target = $target.parents( sel ).first() unless $target.is( sel )

          callback( $target, event )

    definition.stop = true if definition.type == 'click' and ! definition.stop?

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

    $element = @view.get( definition.el )


    if definition.delegate
      delegate_to = @view.selectors[ definition.delegate ] or @view._find_alternate_name( definition.delegate )

      if definition.cancel_delay and definition.cancel_delay > 0
        callback = ( event ) =>
          window.clearTimeout @[ '_' + method_name + '_timeout' ]
          wrapped = wrap( method, definition.stop )
          @[ '_' + method_name + '_timeout' ] = window.setTimeout( ( -> ( wrapped event ) ), definition.cancel_delay )
      else
        callback = wrap method, definition.stop

      throw new Error "Selector not found : #{definition.delegate}" unless delegate_to
      $element.delegate delegate_to.sel, definition.type, callback
      @_dom_bound.push { el: $element, delegate: delegate_to.sel, type: definition.type, callback: callback }
    else
      if definition.cancel_delay and definition.cancel_delay > 0
        callback = ( event ) =>
          window.clearTimeout @[ '_' + method_name + '_timeout' ]
          wrapped = wrap( method, definition.stop )
          @[ '_' + method_name + '_timeout' ] = window.setTimeout( ( -> ( wrapped event ) ), definition.cancel_delay )
      else
        callback = wrap method, definition.stop

      $element.bind definition.type, callback
      @_dom_bound.push { el: $element, type: definition.type, callback: callback }


  destructor: ->
    @view._destructor()
    for bound in @_dom_bound
      if bound.delegate
        bound.el.undelegate bound.delegate, bound.type, bound.callback
      else
        bound.el.unbind bound.type, bound.callback

    delete Darwin.Loader.controllers()[ @id ]



# Documentation is in /doc/view.md
#
class Darwin.View extends Darwin.Base
  _cached: {}

  constructor: ( @$root, options ) ->
    super options
    @_flatten_selectors()
    @$root.find( '.fallback-submits' ).hide()


  run: ->


  get: ( selector_name ) ->
    if @[ "get_#{selector_name}" ]
      @[ "get_#{selector_name}" ]()
    else
      @[ "$#{selector_name}" ] or @_find_element( selector_name )


  _destructor: ->
    @$root.find( '.fallback-submits' ).show()
    @destructor()


  destructor: ->


  clear_cache: ( selector_name ) ->
    if selector_name
      delete @[ "$#{selector_name}" ]
    else
      @clear_cache( selector_name ) for own selector_name, _ of @_cached
      @_cached = {}


  _find_element: ( selector_name ) ->
    definition = @selectors[ selector_name ] or @_find_alternate_name( selector_name )
    if definition
      $base  = if definition.within? then @get( definition.within ) else @$root
      $found = $base.find definition.sel

      unless definition.cache is false
        @[ "$#{selector_name}" ] = $found
        @_cached[ selector_name ] = true

      $found
    else
      $element = @$root.find( "##{selector_name}" )
      if $element.get(0)
        @[ "$#{selector_name}" ] = $element
        @_cached[ selector_name ] = true
        $element
      else
        throw new Error "Selector not found : #{selector_name}"


  _flatten_selectors: ->
    selectors = {}
    walk = ( values, name, parent_names ) ->
      selector_key = ''

      if name
        if parent_names
          selector_key += "#{parent_name.short}_" for parent_name in parent_names

        selector_key += name
        selectors[ selector_key ] = {}

      if typeof values == 'string'
        selectors[ selector_key ] = { sel: values }
      else

        for own attr, value of values
          if $.inArray( attr, [ 'cache', 'sel', 'within' ] ) isnt -1
            selectors[ selector_key ][ attr ] = value
          else
            parents = $.merge [], ( parent_names or [] )
            parents.push({ short: name, long: selector_key }) if name
            walk value, attr, parents

        if name and not values.sel
          selectors[ selector_key ].sel = "##{name}"

      if parent_names and parent_names.length
        selectors[ selector_key ].within = parent_names[ parent_names.length - 1 ].long

      selectors[ selector_key ].alternate_name = name if name

    walk @options.selectors
    @selectors = selectors


  _find_alternate_name: ( name ) ->
    definitions = []

    for selector, definition of @selectors
      definitions.push( definition ) if definition.alternate_name == name

    if definitions.length
      if definitions.length > 1
        throw new Error "Multiple definitions for #{name}"
      else
        definitions[0]
    else
      null


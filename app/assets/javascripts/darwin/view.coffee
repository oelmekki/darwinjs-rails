# Darwin.View is the base class for views, which handle all
# DOM traversal and manipulation.
#
# Darwin.View main purpose is to provide a central configuration
# point between your javascript app and your DOM tree. It also
# eases DOM elements caching.
#
# Actually, elements caching is so important that it's the
# default behavior, and you have to explicitely tell you don't
# want caching on some specific selector.
#
#
# # Selectors
#
# The problem that Darwin.View addresses is breaking your js
# application when you alter your DOM structure.
#
# Consider the following :
#
# ```html
# <aside id="sidebar">
#   <ul class="users">
#     <li>John</li>
#     <li>Joe</li>
#   </ul>
#   <a class="hide">hide</a>
# </aside>
#
# <article>
#   <h1>Users activity</h1>
#
#   <p>Last week, 402 users registered.</p>
#   <p>2311 has been active is that period.</p>
# </article>
# ```
#
# If you want to do special things on users with javascript,
# you'll probably have things like that across your js codebase :
#
# ```coffee
# $( '#sidebar .users li' ).hover( do_stuff )
#
# $( '#sidebar a.hide' ).click( ->
#   $( '#sidebar .users' ).hide()
#   $( '#sidebar a.hide' ).hide()
# )
# ```
#
# Now, what if you decide user list should be called `#user_list`
# rather than `.users` and should be in the article rather than in
# sidebar ? You have to browse your whole codebase to change selectors,
# possibly missing a few and causing crashes.
#
# Darwin.View acts as a center point of configuration for selectors :
#
# ```html
# <div id="page">
#   <aside id="sidebar">
#     <ul class="users">
#       <li>John</li>
#       <li>Joe</li>
#     </ul>
#     <a class="hide">hide</a>
#   </aside>
#   
#   <article>
#     <h1>Users activity</h1>
#   
#     <p>Last week, 402 users registered.</p>
#     <p>2311 has been active is that period.</p>
#   </article>
# </div>
# ```
#
# ```coffee
# class MyView extends Darwin.View
#   @options {
#     selectors:
#       user_list: 
#         'sel': '#sidebar .users'
#         item: 'li'
#       hide_users: '#sidebar a.hide'
#
#   }
# ```
#
# Now, you can use the view to retrieve elements :
#
# ```coffee
# view = new MyView( '#page' ) # note : in real case, controller will initialize
#                              # view, no need to do it yourself.
#
# view.get( 'root' )           # return the root element for view
#
# view.get( 'item' ).hover( do_stuff )
#
# view.get( 'hide_users' ).click( ->
#   view.get( 'user_list' ).hide()
#   view.get( 'hide_users' ).hide()
# )
# ```
#
# Please note a view is always bound to a specific part of the DOM,
# the element passed at initialization (or the element on which
# the data-module attribute is set, if you use Darwin.Loader's
# autoload). All selectors are relative to that element. You may
# retrieve it using `@get( 'root' )`.
#
# If you decide user list should be in article body, all you
# have to do is to change selectors declaration :
#
# ```coffee
# class MyView extends Darwin.View
#   @options {
#     selectors:
#       user_list: 
#         'sel': 'article .users'
#         item: 'li'
#       hide_users: 'article a.hide'
#
#   }
# ```
#
# ... and the change is reflected on your whole codebase.
#
#
# ## Selector declaration
#
# A selector can be either a css selector string or a configuration
# object :
#
# ```coffee
# @options {
#   selectors:
#     foo: '#foos .foo'
#     bar: { 'sel': '#bars .bar' }
# }
# ```
#
# It is recommanded to put configuration keys (like `sel`, here)
# into a string so syntax highlighting make it easy to see selector
# names (`foo`, `bar`) at one glance.
#
# Selectors may be embedded :
#
# ```coffee
# @options {
#   selectors:
#     foo:
#       'sel': '#foos'
#       bar: '#bars'
# }
# ```
#
# `#bars` can be accessed with `view.get( 'foo_bar' )`, which will
# translate to `$( '#foos #bars' )`. If the embedded selector name
# is unambiguous, it can be used directly :
#
# ```coffee
# class MyView extends Darwin.View
#   @options {
#     selectors:
#       foo:
#         'sel': '#foos'
#         wrong: 'p'
#         bar:
#           'sel': '#bars'
#           wrong: 'a'
#   }
#
# view = new MyView( $( '#page' ) )
#
# view.get( 'bar' )                 # Same as view.get( 'foo_bar' ).
#
# view.get( 'wrong' )               # Will throw ambiguous selector error.
#                                   # Use explicit view.get( 'foo_bar_wrong' )
#                                   # or view.get( 'foo_wrong' )
# ```
#
#
# # Caching
#
# The first time you ask view for a selector, it is cached, to avoid
# hitting the DOM again and again when you access elements. This is
# what you want most of the times.
#
# But sometime, you do not want caching. For example, items in a
# list may be added or removed.
#
# You can specify element should not be cached by using the cache option :
#
# ```coffee
# @options {
#   selectors:
#     foo: { 'sel': '#foos', 'cache': false }
# }
# ```
#
# You may also keep default caching, but empty the cache at a given
# point :
#
# ```coffee
#  view.clear_cache( 'foo' ) # removed cache for `foo` selector
#  view.clear_cache()        # empty the whole cache
# ```
#
#
# # Dynamic getter
#
# You can also define methods to retrieve element, be it to create
# the element in first place or because you need specific logic.
# Simply declare a method named after your selector and prefixed
# with `get_` :
#
# ```coffee
# class MyView extend Darwin.View
#   get_foo: ->
#     @$foo ?= $( '<div id="foo"></div>' ).appendTo( @get( 'root' ) )
#
# my_view = new MyView( $( '#page' ) )
# my_view.get( 'foo' )                 # creates #foo and returns it
# ```
#
# You're responsible to cache elements retrieved by getter methods.
#
#
# # Progressive enhancement and graceful degradation
#
# You should build your features so they work without javascript.
# There's a good reason for that : if an error occurs in your
# javascript codebase, events will be deactivated and plain html
# features will ask server to handle the feature.
#
# This means two important things :
#
# * your javascript should prepare DOM on run
# * it should restore its previous state on destruction
#
# Take the following example :
#
# ```html
# <div id="page">
#   <form action="/search" method="post">
#     <input type="search" />
#     <input type="submit" />
#   </form>
# </div>
# ```
#
# ```coffee
# class MyView extends Darwin.View
#   @options {
#     selectors:
#       search_field: 'input[type="search"]'
#       submit: 'input[type="submit"]'
#   }
#
#
#   run: ->
#     @get( 'submit' ).hide()
#
#
#   destructor: ->
#     @get( 'submit' ).show()
# ```
#
# When your view is initialized, the submit button will be hidden.
# You probably will handle search field change through ajax
# request in your controller.
#
# If an error occurs, view's destructor method will be called,
# and the submit input will be shown again, so user can continue
# using the feature.
#
# Therefore, it's important any change you make in the run() method
# has a pending teardown in the destructor() method.
#
# As showing and hiding submit buttons is quite common, their
# handling is natively implemented. For this kind of buttons, simply
# add a `fallback-submits` class on them.
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


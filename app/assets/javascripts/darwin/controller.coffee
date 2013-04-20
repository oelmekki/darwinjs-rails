# Darwin.Controller handles everything event or request related.
# 
# This is the main entry point for all feature. A Controller
# typically initialize a View and bind events to its selectors
# (though you may use a controller without any View if you need
# to).
#
# # Basic usage
#
# Here is a typical controller example :
#
# ```coffee
# class App.Controllers.Users.Index extends Darwin.Controller
#   @options {
#     View: App.Views.Users.Index
#
#     events:
#       'Toggle user block': { el: 'user_trigger', type: 'click' }
#       'Delete user': { el: 'user_block', delegate: 'delete_user', type: 'click' }
#   }
#
#
#   user_trigger_clicked: ->
#     if @view.users_shown()
#       @view.hide_users()
#     else
#       @view.show_users()
#
#   
#   delete_user_clicked: ( $link ) ->
#     if confirm( 'Really delete user ?' )
#       $.get( $link.attr( 'href' ), =>
#         @view.remove_user( $link )
#       )
# ```
#
# All you need to add in your html to use it is a data-module attribute :
#
# ```html
# <div id="users_index" data-module="Users.Index">
#   <-- ... -->
# </div>
# ```
#
# `options.View` declares which view you will use. View is automatically
# initialized at controller initialization.
#
# `options.events` declares which events are handled by the controller.
# You should use this rather than binding events manually for x reasons :
#
# * It offers a central configuration point, so other developers can see
#   at a glance what controller do.
# * It plays well with view selectors, so that you don't have to change
#   every single file if your DOM structure change.
# * Most important, callbacks are wrapped so they are disabled if an error
#   occurs on page.
#
# Event declaration keys are arbitrary strings. This should act as a
# documentation for your controller. Most of the time, knowning the element
# on which the callback is bound and the event type is useless to understand
# what it's supposed to do :
#
# ```coffee
# { el: 'user_trigger', type: 'click' }
# ```
#
# Ok, something happens on user_trigger's click, but what does it do ?
#
# ```coffee
# 'Toggle user block': { el: 'user_trigger', type: 'click' }
# ```
#
# Now, it's clearer.
#
# Callback method names are automatically computed after element and
# event type, so `{ el: 'user_trigger', type: 'click' }` will call the
# `user_trigger_clicked` method. Every callback is passed the element
# as first parameter and the event object as second parameter :
#
# ```coffee
# user_trigger_clicked: ( $trigger, event ) ->
# ```
#
# Note that if you use delegation, delegated element name will be used
# instead of element name :
#
# ```coffee
# class App.Controllers.Users.Index extends Darwin.Controller
#   @options {
#     View: App.Views.Users.Index
#
#     events:
#       'Delete user': { el: 'user_block', delegate: 'delete_user', type: 'click' }
#   }
#
#
#   delete_user_clicked: ( $link ) ->
# ```
#
# # Event declaration options
#
# Here are all options allowed in event declaration :
#
# ## el
#
# A view selector name. Element will be retrieved using `@view.get( <name> )`.
#
# ## type
#
# The event on which to bind the callback. This can be any jQuery event the
# element responds to. So, if you have a plugin that trigger a custom `display`
# event on element, you can use it there.
#
# ## delegate
#
# Use delegation instead of static binding. The selector name
# is retrieved from view, just as `el`.
#
# Delegation not only let bind events on element that are not
# in the page when callback is bound, but also let bind a single
# event instead of hundredth. You probably should use it as much
# as possible.
#
# class App.Controllers.Users.Index extends Darwin.Controller
#   @options {
#     View: App.Views.Users.Index
#
#     events:
#       'Delete user': { el: 'user_block', delegate: 'delete_user', type: 'click' }
#   }
#
#
#   delete_user_clicked: ( $link ) ->
# ```
#
# This binds a single callback to handle as many users you want,
# and also handle users you've added in the list after controller
# initialization.
#
# ## controller_method
#
# Use a custom method name rather than automatically computed one.
# You may use this, for example, if you want to use the same callback
# for two events.
#
# Sometime, automatically computed name will just not do it. For example,
# Darwin.Controller does not use any special inflection other than
# adding a 'd' rather than 'ed' for words that end with 'e'. So,
# here are the computed method names :
#
# ```coffee
# { el: 'foo', type: 'click' }  # => foo_clicked
# { el: 'foo', type: 'change' } # => foo_changed
# { el: 'foo', type: 'show' }   # => foo_showed
# ```
#
# For proper english, you can use `controller_method` :
#
# ```coffee
# 'Update page title': { el: 'foo', type: 'show', controller_method: 'foo_shown' }
# ```
#
# ## view_method
#
# If your callback simply call a view method, you don't need
# to create a controller method for that :
#
# ```coffee
# foo_clicked: ->
#   @view.show_something()
# ```
#
# Instead, you can declare this method in event definition :
#
# ```coffee
# 'Show something': { el: 'foo', type: 'click', view_method: 'show_something' }
# ```
#
# `controller_method` and `view_method` are mutually exclusive.
#
# ## stop
#
# By default, any click event calls `event.preventDefault()` and
# `event.stopPropagation()`, because it's what we need most of the time.
#
# You may not want that, for example, when you want to ask a confirmation
# to user. In that case, you can declare `stop: false` :
#
# ```coffee
# class App.Controllers.Users.Index extends Darwin.Controller
#   @options {
#     View: App.Views.Users.Index
#
#     events:
#       'Delete user': { el: 'delete_user', type: 'click', stop: false }
#   }
#
#
#   delete_user_clicked: ( $link, event ) ->
#     event.preventDefault() unless confirm( 'seriously ?' )
# ```
#
# Reversively, you can force stopping on other events :
#
# ```coffee
# 'Troll ie users': { el: 'user_checkbox', type: 'change', stop: true }
# ```
#
# ## cancel_delay
#
# Sometime, you want to wait for a short time on an event before
# executing its callback, and potentialy cancel it if the same
# event occurs.
#
# You will use that typically on an ajax autocomplete search box :
# when user press a key, you wait for 500ms before firing the request
# to see if she did not added an other letter. You can use cancel_delay
# for that :
#
# ```coffee
# 'Autocomplete search': { el: 'search_input', type: 'change', cancel_delay: 500 }
# ```
#
# cancel_delay value is in milliseconds.
#
#
# ## ensure_element
#
# To preserve `this` context as being the controller, event binding
# use event.target to retrieve element on which event occurs. This
# has implications. If you have :
#
# ```html
# <a href="/do_stuff"><img src="my_image.jpg"></a>
# ```
#
# and you bind event on the link, `event.target` may be the image
# element if you clicked on it. Darwin is aware of that on will
# always retrieve the element you asked when passing it to callback.
#
# But sometime, you may just want to have that target element.
# You can achieve this using `ensure_element` :
#
# ```coffee
# 'Remove clicked element': { el: 'my_block', type: 'click', ensure_element: false }
# ```
#
# You probably should use delegation to filter what you want
# more precisely, though.
#
#
# # Progressive enhancement and graceful degradation
#
# Like Darwin.View, Darwin.Controller has a `run()` and
# a `destructor()` method.
#
# You may, for example, use `run()` to instantiate plugins.
# Put their teardown calls in `destructor()`.
#
# If you override `destructor()`, don't forget to call `super`,
# as controller destruction already handle a lot of stuff under
# the hood, like calling its view destructor, unbinding events
# and removing references to controller.
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



# Darwin.Loader ensure only the needed javascript is executed.
#
# # Autoloading
#
# If you do something like this :
#
# ```coffee
# $( '#my_module' ).each( ( i, el ) ->
#   new App.Controllers.MyModule( $(el) )
# )
# ```
#
# You may think it's ok even if `#my_module` is only present on a
# single page of your application, because jQuery will simply do
# nothing if it doesn't find the element.
#
# It's not ok. If you do that, DOM will be hit to find the element
# on every single page. Hitting the DOM is expansive, you should not
# do it if it's not necessary. When you'll have 100 controllers in
# your app and DOM hitted 100 times on each page load to find module
# elements, slow js engines will begin to suffer before you actually
# do anything.
#
# Darwin.Loader provides a mean to only load what you need. Add a
# data-module attribute to the target block, and Darwin.Loader will
# do a single DOM request to retrieve '*[data-module'] and initialize
# your controllers :
#
# ```html
#   <div id="users" data-module="AdminArea.Users.Show">
#     <ul>
#       <li>John</li>
#       <li>Joe</li>
#     </ul>
#   </div>
# ```
#
# is equivalent to :
#
# ```coffee
# new App.Controllers.AdminArea.Users.Show( $( '#users' ) )
# ```
#
# To start, loader, add this in your application code :
#
# ```coffee
# Darwin.Loader.run()
# ```
#
#
# # Error handling
#
# Darwin takes error handling seriously. The default behavior is to
# deactivate javascript app on any error occuring in it. If your app
# code produce an error, all its event callbacks are deactivated and
# controllers' destructor methods are called. This is a good thing.
#
# Consider the following :
#
# ```html
# <div id="items"></div>
# <a href="#">show more</a>
# ```
#
# ```coffee
# $( 'a' ).click( ->
#   please_crash()
#   $( '#items' ).load( '/more_items' )
# )
# ```
#
# What happens when you click the link ? Nothing. What happens if
# you click again ? And again, and again ? Still nothing. At this
# point if you're a developer, your instinct will suggest you reload
# the page. Other people will get angry because "it does not work" and
# leave your application.
#
# Here is the proper Darwin equivalent :
#
# ```html
# <div data-module="ShowMore">
#   <div id="items"></div>
#   <a href="/show_more">show more</a>
# </div>
# ```
#
# ```coffee
# class App.Views.ShowMore extends Darwin.View
#   @options {
#     link: 'a'
#     items: '#items'
#   }
#
# class App.Controllers.ShowMore extends Darwin.Controller
#   @options {
#     View: App.Views.ShowMore
#
#     events:
#       'Display more items': { el: 'link', type: 'click' }
#   }
#
#   link_clicked: ( $link ) ->
#     please_crash()
#     @view.get( 'items' ).load( "#{$link.attr( 'href' )} #items" )
# ```
#
# When you click the first time, error will occurs and nothing
# will happen. If you click a second time, as event callbacks have
# been deactivated, the link will be followed and user won't realize
# something bad happened. That means, by the way, that javascript
# will have been reloaded.
#
# Additionnaly, if you provided an url in the `window.js_exception_url`,
# an ajax request will be fired to report the error.
#
controllers = {}
errors_got = 0

loader = Darwin.Loader =
  run: ->
    loader.module_roots().each( ( i, $module ) =>
      $module     = $( $module )
      module_name = loader.compute_name( $module.attr( 'data-module' ) )
      path        = $module.attr( 'data-module' ).split( '.' )
      module      = App.Controllers
      module      = module[ path.shift() ] while path.length

      if module
        controllers[ module_name ]    = new module( $module )
        controllers[ module_name ].id = module_name
      else
        throw new Error( "Can't find module #{$module.attr( 'data-module' )}" )
    )


  module_roots: ->
    $( '*[data-module]' )


  compute_name: ( module_path ) ->
    name = module_path.replace( /\./g, '_' ).toLowerCase()

    if controllers[ name ]
      i = 1

      for own controller_name, controller of controllers
        i++ if controller_name.indexOf( name ) isnt -1

      name = "#{name}_#{i}"

    name

  controllers: ->
    controllers

window.onerror = ( error, url, lineno ) =>
  if url && url.match( /https?:\/\/.*?assets/ )
    @crashed = true
    console?.log( "Error on #{url}, line #{lineno}" )
    errors_got += 1

    if window.js_exception_url and errors_got <= 5
      $.post( window.js_exception_url, js_error: { error: error, url: url, lineno: lineno, page_url: window.location.href } )

    for own controller_name, controller of controllers
      controller.destructor() if controller.options.failsafe is true
  error

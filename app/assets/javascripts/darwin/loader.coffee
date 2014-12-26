# Documentation is in /doc/loader.md
#
controllers = {}
errors_got = 0

loader = Darwin.Loader =
  run: ->
    loader.load_modules()

  load_modules: ( $element = $ )
    $element.find( '*[data-module]' ).each( ( i, $module ) =>
      $module = $( $module )
      loader.load_module( $module.attr( 'data-module' ), $module )
    )

  load_module: ( pathname, $root ) ->
    module_name = loader.compute_name( pathname )
    path        = pathname.split( '.' )
    module      = App.Controllers
    module      = module[ path.shift() ] while path.length

    if module
      controllers[ module_name ]    = new module( $root )
      controllers[ module_name ].id = module_name
    else
      throw new Error( "Can't find module #{pathname}" )

    controllers[ module_name ]

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

previous_onerror = window.onerror
window.onerror = ( error, url, lineno, error_object ) =>
  if url && url.match( /https?:\/\/.*?assets/ )
    @crashed = true
    console?.log( "Error on #{url}, line #{lineno}" )
    errors_got += 1

    if window.js_exception_url and errors_got <= 5
      $.post( window.js_exception_url, js_error: { error: error, url: url, lineno: lineno, page_url: window.location.href } )

    for own controller_name, controller of controllers
      controller.destructor() if controller.options.failsafe is true

  if previous_onerror then previous_onerror( error, url, lineno, error_object ) else error

Darwin._events = {}

Darwin.on = ( event_name, callback ) ->
  Darwin._events[ event_name ] ?= []
  Darwin._events[ event_name ].push( callback )
  null

Darwin.trigger = ( event_name, params... ) ->
  if ( callbacks = Darwin._events[ event_name ] )
    callback( params... ) for callback in callbacks

  null

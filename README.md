# Darwinjs::Rails

Darwin is a javascript framework for people that take error
handling seriously and want to achieve it through progressive
enhancement and graceful degradation.

Darwin will also let developer write clean and encapsulated
code that encourages self documentation.

## Installation

Add this line to your application's Gemfile:

    gem 'darwinjs-rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install darwinjs-rails

## Getting Started

You can generate a javascript module using the provided
generator :

```
$ rails generate darwin:assets users/index

      create  app/assets/javascripts/controllers/users.coffee
      create  app/assets/javascripts/views/users.coffee
      create  app/assets/javascripts/controllers/users/index.coffee
      create  app/assets/javascripts/views/users/index.coffee
```

This will create your controller and your view in the `users` namespace.

Add autoloader in your application.coffee file :

```
$(->
  Darwin.Loader.run()
)
```

Now add a `data-module` attribute in your users index view to
autoload your module :

```erb
<div id="users" data-module="User.Index">
  <ul>
  <% @users.each do |user| %>
    <%= render 'user', user: user %>
  <% end %>
  </ul>
</div>
```

This will automatically initialize your module.

A module is composed of two files :

* a controller that handles events
* a view that handles DOM manipulation

Here is a typical view :

```coffee
class App.Controllers.Users.Index extends Darwin.Controller
  @options {
    selectors:
      show_users: 'a#show_users'
      user_block: '#users'
      user:
        'sel': '.user'
        more: '.more a'
        delete: 'a[data-method="delete"]'
  }

  show_info_for( $link ) ->
    $link.next( '.info' ).show()

  remove_user_for( $link ) ->
    $link.parent().remove()
```

And the corresponding controller :

```coffee
class App.Controllers.Users.Index extends Darwin.Controller
  @options {
    View: App.Views.Users.Index

    events:
      'Toggle user block':      { el: 'show_users', type: 'click' }
      'Show user info':         { el: 'user_more', type: 'click' }
      'Delete user on server':  { el: 'user_delete', type: 'click' }
  }


  show_users_clicked: ->
    @view.get( 'user_block' ).fadeIn()


  user_more_clicked: ( $link ) ->
    @view.show_info_for( $link )

  
  user_delete_clicked: ( $link ) ->
    if confirm( 'Really delete user ?' )
      $.get( $link.attr( 'href' ), =>
        @view.remove_user_for( $link )
      )
```

As you see, a view acts as single point of configuration for selectors.
Any change needed then reflect to the whole javascript codebase.

In the same way, controller acts as a single point of configuration
for events. You can tell what a module does looking at the first
lines of the controller file.

But there is more happening under the hood, here. First, all you DOM
elements retrieved by view selectors are cached. Upon further call
they are retrieved without hitting the DOM again, which is very
costly in term of performances.

Furthermore, all event callbacks are wrapped so that they do not
execute if an error occured. In case of error, events are simply
deactivated and any link is followed, reloading the page and letting
server side handle what has to be done, so your user doesn't even
notice something got wrong.

Ready for more ? See [introduction](wiki/Introduction).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

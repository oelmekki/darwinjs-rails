#= require_self
#= require './darwin/base'
#= require './darwin/loader'
#= require './darwin/template'
#= require './darwin/view'
#= require './darwin/controller'
#
# Darwin is a javascript framework for people that take error
# handling seriously and want to achieve it through progressive
# enhancement and graceful degradation.
#
# Darwin will also let developer write clean and encapsulated
# code that encourages self documentation.
#
#
# # Module
#
# At the core of darwin is the concept of module : a module
# is a specific feature, bound to a specific block of your
# page. This block will be the root of your feature and will
# act as a sandbox. Of course, you may decide to have the whole
# page content except layout as root, or you can choose to
# have a lot of modules which will speak to each other via
# events and callbacks. You can even have modules inside
# modules : that's up to you, darwin will support you anyway.
#
# A module is made of a controller and an optional (but almost
# always present) view. Controllers are declared on 
# `App.Controllers` and views are declared on `App.Views`. You
# can (and are expected to) create namespaces within those.
#
# The suggested file structure is this one :
# 
# ```
# app/assets/javascripts/
#   controllers/
#     users.coffee        # declare namespace : App.Controllers.Users = {}
#     users/
#       index.coffee      # Controller for index action
#       show.cofee        # Controller for show action
#       followers.coffee  # Controller for the "followers" block
#   views/
#     users.coffee        # declare namespace : App.Views.Users = {}
#     users/
#       index.coffee      # View for index action
#       show.cofee        # View for show action
#       followers.coffee  # View for the "followers" block
# ```
#
# Your application.coffee file should `require_tree` views/ before
# controllers/, as controllers depend on views.
#
# You can easily create a module using the generator provided :
#
# ```
# $ rails generate darwin admin_area/users/index
#
#       create  app/assets/javascripts/controllers/admin_area.coffee
#       create  app/assets/javascripts/views/admin_area.coffee
#       create  app/assets/javascripts/controllers/admin_area/users.coffee
#       create  app/assets/javascripts/views/admin_area/users.coffee
#       create  app/assets/javascripts/controllers/admin_area/users/index.coffee
#       create  app/assets/javascripts/views/admin_area/users/index.coffee
# ```
#
# You can also create modules for an whole CRUD resource using camelcase
# form :
#
# $ rails g darwinjs:assets AdminArea::Contact
#       create  app/assets/javascripts/controllers/admin_area.coffee
#       create  app/assets/javascripts/views/admin_area.coffee
#       create  app/assets/javascripts/controllers/admin_area/contacts.coffee
#       create  app/assets/javascripts/views/admin_area/contacts.coffee
#       create  app/assets/javascripts/controllers/admin_area/contacts/index.coffee
#       create  app/assets/javascripts/views/admin_area/contacts/index.coffee
#       create  app/assets/javascripts/controllers/admin_area/contacts/edit.coffee
#       create  app/assets/javascripts/views/admin_area/contacts/edit.coffee
#       create  app/assets/javascripts/controllers/admin_area/contacts/show.coffee
#       create  app/assets/javascripts/views/admin_area/contacts/show.coffee
#       create  app/assets/javascripts/controllers/admin_area/contacts/new.coffee
#       create  app/assets/javascripts/views/admin_area/contacts/new.coffee
#       create  app/assets/javascripts/controllers/admin_area/contacts/form.coffee
#       create  app/assets/javascripts/views/admin_area/contacts/form.coffee
#   ```
#
# Module can be autoloaded, using the `data-module` attribute :
#
# ```
# <div id="users" data-module="Users.Index">
# ...
# </div>
# ```
#
# This will instantiate `App.Controllers.Users.Index` (which in turn
# instantiates its view).
#
# To learn more about autoloader, see [Loader](darwin/loader.js).
#
#
# # Controller
#
# A controller will handle anything event or request specific.
# An option set let you define all your events so you can see
# at one glance what the controller is about. See the
# options.events block here :
#
# ```coffee
# class App.Controllers.Users.Index extends Darwin.Controller
#   @options {
#     View: App.Views.Users.Index
#
#     events:
#       'Toggle user block':      { el: 'user_trigger', type: 'click' }
#       'Show user info':         { el: 'user_more_trigger', type: 'click' }
#       'Delete user on server':  { el: 'user_delete', type: 'click' }
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
#   user_more_trigger_clicked: ( $link ) ->
#     @view.show_info_for( $link )
#
#   
#   user_delete_clicked: ( $link ) ->
#     if confirm( 'Really delete user ?' )
#       $.get( $link.attr( 'href' ), =>
#         @view.remove_user( $link )
#       )
# ```
#
# Such self documentation will make sure any developer coming after
# you will understand immediately what the controller is about.
#
# As you probably noticed, callback names are automatically computed
# to match your event declaration, so `{ el: user_trigger, type: click}`
# call a `user_trigger_clicked` callback. Two parameters are passed
# to your callback : the jquery extended element and the event object.
#
# As most of the time, you want to stop an event after a click, this
# also is the default. So :
#
# ```coffee
# class App.Controllers.Users.Index extends Darwin.Controller
#   @options {
#     View: App.Views.Users.Index
#
#     events:
#       'Toggle user block': { el: 'user_trigger', type: 'click' }
#   }
#
#   user_trigger_clicked: ( $link )->
#     @view.show_user( $link )
# ```
#
# Is equivalent to, without darwin :
#
# ```
#   $('.user_trigger' ).click( ( event ) ->
#     $link = $(this)
#     event.preventDefault()
#     show_user( $link )
#   )
# ```
#
# Read about [Controller](darwin/controller.coffee) to learn more.
#
# # View
#
# A view handle everything DOM related. Its main purpose is
# to act as central point of configuration for selectors and
# to do DOM manipulation :
#
# ```coffee
# class App.Controllers.Users.Index extends Darwin.Controller
#   @options {
#     selectors:
#       close: 'a.close'
#       show_more: '.content .more a'
#       users:
#         'sel': '#users'
#         delete: 'a[data-method="delete"]'
#   }
# ```
#
# Now, everywhere in your view methods, you can use `@get( 'close' )`
# to retrieve your close element. In controllers, you can use
# `@view.get( 'close' )` as well. This has two benefits :
#
# 1. You have a single point of configuration. If you decide to
# change your DOM, you only have to change configuration here and
# it is reflected on your whole module.
# 2. All elements are cached by default. Don't worry anymore about
# DOM hitting performances.
#
# A view is also responsible for setup / teardown your DOM, via
# its `run()` and `destructor()` method. `run()` is called when
# module is initialized ; `destructor()` is called when an error
# occurs (or you manually destruct the module).
#
# ```coffee
# class App.Controllers.Users.Index extends Darwin.Controller
#   @options {
#     selectors:
#       submits: 'input[type="submit"]'
#   }
#
#   run: ->
#     @get( 'submits' ).hide()
#
#
#   destructor: ->
#     @get( 'submits' ).show()
# ```
#
# So, `run()` is for progressive enhancement, and `destructor()` is
# for graceful degradation.
#
# This will ensure your featureis still # usable even if a
# javascript error occurs.
#
# To learn more about views, see [View](darwin/view.coffee).
#

window.Darwin = {}

window.App =
  Views:        {}
  Controllers:  {}
  Helpers:      {}

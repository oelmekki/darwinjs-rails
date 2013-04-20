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

window.Darwin = {}

window.App =
  Views:        {}
  Controllers:  {}
  Helpers:      {}

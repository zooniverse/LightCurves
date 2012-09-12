require('lib/setup')

Spine = require('spine')

Lang = require 'lib/en'
Main = require 'controllers/main'

class App extends Spine.Controller
  constructor: ->
    super
    
    @main = new Main
    
    @append @main
    Spine.Route.setup()

module.exports = App
    

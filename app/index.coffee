require('lib/setup')

Spine = require('spine')

Main = require 'controllers/main'

class App extends Spine.Controller
  constructor: ->
    super
    
    @main = new Main
    
    Spine.Route.setup()    
    
module.exports = App
    

require('lib/setup')

Spine = require('spine')

Header = require 'controllers/header'
Main = require 'controllers/main'

Network = require 'lib/network'

class App extends Spine.Controller
  constructor: ->
    super
    
    @header = new Header
      el: "#header"
    
    @main = new Main
      el: "#content"
    
    Network.init(@header.payment)
    
    Spine.Route.setup()
    @header.active()    
    
module.exports = App
    

require('lib/setup')

Spine = require('spine')

ClassifyHelp = require 'controllers/classify_help'
Header = require 'controllers/header'
Main = require 'controllers/main'

Network = require 'lib/network'
TSClient = require 'turkserver-js-client'

class App extends Spine.Controller
  constructor: ->
    super
    
    @classify_help = new ClassifyHelp
      el: "#help-overlay"
    
    @header = new Header
      el: "#header"
    
    @main = new Main
      el: "#content"
    
    Network.init(@header.payment)
    
    Spine.Route.setup
      shim: not TSClient.localMode
    
    @classify_help.active()
    @header.active()    
    
module.exports = App
    

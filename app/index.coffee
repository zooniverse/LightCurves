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
    
    if $.browser.msie
      return false
        
    # Remove browser warnings
    $("#content").empty()
    
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
    
    # Set blur and focus events - not that great for detecting stuff
#    $(window).focus ->
#      console.log "focused"      
#    $(window).blur ->
#      console.log "blurred"
    
module.exports = App
    

Spine = require('spine')

Network = require 'lib/network'

class ClassifyHelp extends Spine.Controller
  className: "help-overlay"
  
  events:
    # not both of these should be called
    "click": "close" # Should we allow closing anywhere?
    "click a.big-button": "close"
  
  constructor: ->
    super
    
    Spine.bind "showHelp", =>
      @render()
      @el.css("visibility", "visible")
      
    Spine.bind "showMessage", (msg) => 
      @html require('views/modal_alert')(msg)
      @el.css("visibility", "visible")      
  
  active: ->
    super
  
  render: ->
    @html require 'views/classify_help'    
    
  close: (ev) =>
    ev.preventDefault()
    ev.stopPropagation() # don't be called twice if button is clicked
    @el.css("visibility", "hidden")
    Network.activity "Closed Modal Dialog"
    
module.exports = ClassifyHelp

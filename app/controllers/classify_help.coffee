Spine = require('spine')

Network = require 'lib/network'

class ClassifyHelp extends Spine.Controller
  className: "help-overlay"
  
  events:
    "click": "close" # Allows closing anywhere, stop bubble up from immediates
    "click a.cancel": "close"
    "click a.big-button.close": "close"
    "click a.big-button.confirm": "confirm"
  
  constructor: ->
    super
    
    Spine.bind "showHelp", =>
      @render()
      @el.css("visibility", "visible")
      
    Spine.bind "showMessage", (msg) => 
      @html require('views/modal_alert')(msg)
      @el.css("visibility", "visible")
     
    Spine.bind "showConfirm", (msg, callback) =>
      # Display confirm dialog
      @html require('views/modal_confirm')(msg)
      @el.css("visibility", "visible")
      @confirm_cb = callback
  
  active: ->
    super
  
  render: ->
    @html require 'views/classify_help'    
  
  confirm: (ev) =>
    ev.preventDefault()
    ev.stopPropagation()  
    @el.css("visibility", "hidden")
    @confirm_cb?()
        
  close: (ev) =>
    ev.preventDefault()
    ev.stopPropagation() # don't be called twice if button is clicked
    @el.css("visibility", "hidden")
    Network.activity "Closed Modal Dialog"
    
module.exports = ClassifyHelp

Spine = require('spine')

class ClassifyHelp extends Spine.Controller
  className: "help-overlay"
  
  events:
    "click": "close" # Should we allow closing anywhere?
    "click a.big-button": "close"
  
  constructor: ->
    super
  
  active: ->
    super
    @render()
  
  render: ->
    @html require 'views/classify_help'    
    
  close: (ev) =>
    ev.preventDefault()
    @el.css("visibility", "hidden")
    
module.exports = ClassifyHelp

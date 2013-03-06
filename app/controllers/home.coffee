Spine = require('spine')

class Home extends Spine.Controller
  className: "textpage"

  events:
    "click .start_hunting .big-button": "start"

  constructor: ->
    super

  active: ->
    super
    @render()
    
  render: =>
    @html require('views/home')(@)
    
  start: (ev) ->
    ev.preventDefault()
    @navigate '/tutorial'
        
module.exports = Home

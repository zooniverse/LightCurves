Spine = require('spine')

class Home extends Spine.Controller

  events:
    "click .start_hunting .button": "start"

  constructor: ->
    super
    @el.attr('id', 'home')

  active: ->
    super
    @render()
    
  render: =>
    @html require('views/home')(@)
    
  start: (ev) ->
    ev.preventDefault()
    @navigate '/sources', 'APH10154043'
        
module.exports = Home

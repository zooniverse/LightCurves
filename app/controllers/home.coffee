Spine = require('spine')

class Home extends Spine.Controller
  el: "#carrousel"

  constructor: ->
    super

  active: ->
    super
    @render()
    
  render: =>
    @html require('views/home')(@)
        
module.exports = Home

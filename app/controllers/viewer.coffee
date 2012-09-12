Spine = require('spine')

Lightcurve = require('models/lightcurve')

class Viewer extends Spine.Controller
  
  @width = 670
  @height = 440
  
  elements:
    '#graph': 'graph'
    '#zoom': 'zoom'
  
  # events:
  
  
  constructor: ->
    super
  
  teardown: => # Clean things up 
  
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/lightcurve')(@)
  
  zoom: ->
    # do stuff
  

          
module.exports = Viewer

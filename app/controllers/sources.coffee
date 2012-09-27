Spine = require('spine')

Lightcurve = require 'models/lightcurve'

Viewer = require 'controllers/viewer'

class Sources extends Spine.Controller
  className: "lightcurve"
  
  constructor: ->
    super
    @el.attr('id', 'sources')
    
    @viewer = new Viewer
      containerSelector: "#sources.lightcurve"
      allow_annotations: false
      show_simulations: true
  
  active: (params) ->
    super
    @zooniverse_id = params.zooniverse_id
    @refresh()

  deactivate: ->
    super
    @viewer?.teardown()
  
  refresh: =>
    return unless @isActive() and @zooniverse_id
    
    @lightcurve = new Lightcurve(zooniverse_id: @zooniverse_id)
    @lightcurve.fetchWithProxy @lcMetaLoaded, @lcDataLoaded    
  
  render: ->
    @html require('views/source')(@)
    @append @viewer
    @viewer.render()
  
  lcMetaLoaded: =>
    @render()
    
  lcDataLoaded: =>
    @viewer.loadData @lightcurve 
    
  round_float: (x, n) ->
    n = 0  unless parseInt(n)
    return false  unless parseFloat(x)
    Math.round(x * Math.pow(10, n)) / Math.pow(10, n)
    
module.exports = Sources

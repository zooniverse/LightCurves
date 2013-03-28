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
    
    @viewer.active()    

  deactivate: ->
    super
    @viewer?.teardown()
  
  refresh: =>
    return unless @isActive() and @zooniverse_id
    
    @lightcurve = new Lightcurve(zooniverse_id: @zooniverse_id)
    @lightcurve.fetch @lcMetaLoaded, @lcDataLoaded    
  
  render: ->
    @html require('views/source')(@)
    
    @append @viewer.render()
    
    # @viewer.render()
  
  lcMetaLoaded: =>
    @render()
    
  lcDataLoaded: =>
    @viewer.loadData @lightcurve 
  
module.exports = Sources

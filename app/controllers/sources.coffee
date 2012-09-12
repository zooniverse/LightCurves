Spine = require('spine')
Lightcurve = require 'models/lightcurve'
Viewer = require 'controllers/viewer'

class Sources extends Spine.Controller
  constructor: ->
    super
  
  active: (params) ->
    super
    @zooniverse_id = params.id
    @refresh()
    @render()
  
  deactivate: ->
    super
    @viewer?.teardown()
  
  refresh: =>
    return unless @isActive() and @zooniverse_id
    @loading = true
    
    Lightcurve.lookup \
      @zooniverse_id, 
      @getJSON,
      ( => @error = true )
  
  render: =>
    @html require('views/source')(@)
  
  getJSON: (json) => 
    @lightcurve = new Lightcurve(json.light_curve)
    setup_lightcurve_data_on_page objJson.light_curve
    load_light_curve_data objJson.light_curve.light_curve_url        
    @render
    
module.exports = Sources

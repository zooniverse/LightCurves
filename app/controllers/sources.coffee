Spine = require('spine')
LightcurveMeta = require 'models/lightcurveMeta'
Viewer = require 'controllers/viewer'

class Sources extends Spine.Controller
  
  constructor: ->
    super
    @el.attr('id', 'lightcurve')
    
    @viewer = new Viewer()
  
  active: (params) ->
    super
    @zooniverse_id = params.zooniverse_id
    @refresh()
    @render()    

  deactivate: ->
    super
    @viewer?.teardown()
  
  refresh: =>
    return unless @isActive() and @zooniverse_id
    
    uri = "http://www.planethunters.org/light_curves/next_light_curve?lightcurve_id=#{ @zooniverse_id }&format=json"
    jqxhr = $.getJSON \
      "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22" \
        + encodeURIComponent(uri) + "%22&format=json&callback=?"
              
    jqxhr.success @loadLCMeta
    jqxhr.error( -> alert "error getting proxied lightcurve json" ) # change to some error view  
  
  render: ->
    @html require('views/source')(@)
    @append @viewer
    @viewer.render()
  
  loadLCMeta: (yql) =>
    unless yql.query.results
      alert("Failed to get metadata for " + @zooniverse_id)
      return      
    json = $
    .parseJSON(yql.query.results.body.p)
    @lightcurve = new LightcurveMeta(json.light_curve)
        
    xopt = $.jsonp
      url: @lightcurve.light_curve_url
      callback: 'light_curve_data'
      error: -> alert(t('lightcurve.failed_to_get') + @lightcurve.light_curve_url)
      success: @loadLCData
    
    @render()
    
  loadLCData: (json) =>
    @viewer.loadData(json, @lightcurve)
    
  round_float: (x, n) ->
    n = 0  unless parseInt(n)
    return false  unless parseFloat(x)
    Math.round(x * Math.pow(10, n)) / Math.pow(10, n)
    
module.exports = Sources

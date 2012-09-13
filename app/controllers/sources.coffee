Spine = require('spine')
Lightcurve = require 'models/lightcurve'
Viewer = require 'controllers/viewer'

class Sources extends Spine.Controller
  el: '#lightcurve'
  
  constructor: ->
    super
  
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
    @loading = true
    
    uri = "http://www.planethunters.org/light_curves/next_light_curve?lightcurve_id=#{ @zooniverse_id }&format=json"
    jqxhr = $.getJSON \
      "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22" \
        + encodeURIComponent(uri) + "%22&format=json&callback=?"
              
    jqxhr.success @loadLCMeta    
    # Somehow, these all get called?
#    jqxhr.success alert("got the yql!")
#    jqxhr.error alert("error getting proxied lightcurve json") # change to some error view      
    @render()  
  
  render: =>
    @html require('views/source')(@)
  
  loadLCMeta: (yql) =>
    unless yql.query.results
      alert("Failed to get metadata for " + @zooniverse_id)
      return      
    json = $
    .parseJSON(yql.query.results.body.p)
    @lightcurve = new Lightcurve(json.light_curve)
        
    xopt = $.jsonp
      url: @lightcurve.light_curve_url
      callback: 'light_curve_data'
      error: -> alert(t('lightcurve.failed_to_get') + @lightcurve.light_curve_url)
      success: @loadLCData
    
    @render()
    
  loadLCData: (json) =>
    console.log json  
    
  round_float: (x, n) ->
    n = 0  unless parseInt(n)
    return false  unless parseFloat(x)
    Math.round(x * Math.pow(10, n)) / Math.pow(10, n)
    
module.exports = Sources

Spine = require('spine')

Network = require 'lib/network'

Source = require 'models/source'

class Lightcurve extends Spine.Model
  @configure 'Lightcurve', 'zooniverse_id', 'meta', 'source', 'data'  
  
  # Random meta fields used in old viewer:
  # 'light_curve_url', 'source', 'priority', 'rel_start_time'
  
  @tutorialLightcurve: ->
    return new Lightcurve(tutorial: true)
      
  constructor: ->
    super
  
  fetch: (metaCallback, dataCallback) =>    
    @dataCallback = dataCallback
      
    unless @tutorial
      @metaCallback = metaCallback
      jqxhr = $.getJSON('http://' + Network.serverport + '/light_curves/' + @zooniverse_id)
      jqxhr.success (data) =>
        unless data
          alert("Failed to get metadata for " + @zooniverse_id)
          return
        @fetchData data
      jqxhr.error => alert("Failed to get metadata for " + @zooniverse_id)
    else
      $.jsonp
        url: '/tutorial_light_curve.json'
        callback: 'light_curve_data'
        error: -> alert(t('lightcurve.failed_to_get') + 'tutorial')
        success: @loadData    
      metaCallback()  
    
  fetchWithProxy: (metaCallback, dataCallback) =>
    if @tutorial
      alert 'Y U TRY TO FETCH REAL DATA FOR TUTORIAL?'
      return
      
    @metaCallback = metaCallback
    @dataCallback = dataCallback
    
    uri = "http://www.planethunters.org/light_curves/next_light_curve?id=#{ @zooniverse_id }&format=json"      
    
    jqxhr = $.getJSON \
      "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22" \
        + encodeURIComponent(uri) + "%22&format=json&callback=?"  
    
    jqxhr.success (yql) =>
      unless yql.query.results
        alert("Failed to get metadata for " + @zooniverse_id)
        return      
      json = $.parseJSON(yql.query.results.body.p)
      @fetchData json
      
    jqxhr.error( -> alert "error getting proxied lightcurve json" ) # change to some error view  
  
  fetchData: (json) =>    
    @meta = json.light_curve    
    @source = new Source(@meta.source) if @meta.source
    
    @metaCallback?()
    
    $.jsonp
      url: @meta.light_curve_url
      callback: 'light_curve_data'
      error: -> alert(t('lightcurve.failed_to_get') + @meta.light_curve_url)
      success: @loadData
    
  loadData: (data) =>  
    if not data or data.length <= 0 
      alert(t('lightcurve.problem')) 
      return
  
    # FIXME: Meta is incorrect for later curves
    @data = if data.meta_data then data.data else data 

    ymax = 0
    ymin = 1000000
    
    # FIXME: Only minor preprocessing done here.
    i = 0
    while i < @data.length
      point = @data[i]
      if point.y > 0
        # Fix textual values in synthetics.
        point.y = point.y * 1
        point.dy = point.dy * 1
        point.tr = Math.floor(point.tr)
        
        ymax = point.y if point.y > ymax
        ymin = point.y if point.y < ymin
      i++      
    
    @start = @data[0].x
    @end = @data[@data.length-1].x
    
    @yrange = ymax - ymin
    @ymax = ymax + 0.15 * @yrange
    @ymin = ymin - 0.15 * @yrange
    
    @dataCallback?()    
            
module.exports = Lightcurve

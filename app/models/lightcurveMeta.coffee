Spine = require('spine')

class LightcurveMeta extends Spine.Model
  @configure 'Lightcurve', 'light_curve_url', \
  'source', 'priority', 'rel_start_time'
  
  @loadWithProxy: (zooniverse_id) ->   
    uri = "http://www.planethunters.org/light_curves/next_light_curve?lightcurve_id=#{ zooniverse_id }&format=json"
    
    jqxhr = $.getJSON \
      "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22" \
        + encodeURIComponent(uri) + "%22&format=json&callback=?"
  
  constructor: ->
    super    
    @synthetic = true if @source.kind is "simulation"
    @planet = true if @source.kind is "planet"
          
module.exports = LightcurveMeta

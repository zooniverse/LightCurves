Spine = require('spine')

class Lightcurve extends Spine.Model
  @configure 'Lightcurve', 'source', 'priority', 'rel_start_time'
  
  @lookup: (zooniverse_id, callback, error) ->
    $.jsonp
      url: "http://www.planethunters.org/light_curves/next_light_curve?lightcurve_id=#{ zooniverse_id }?callback=?"
      success:  callback
      error:    error  
  
  constructor: ->
    super    
    @synthetic = true if @source.kind is "simulation"
    @planet = true if source.kind is "planet"
          
module.exports = Lightcurve

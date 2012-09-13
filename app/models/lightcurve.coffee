Spine = require('spine')

class Lightcurve extends Spine.Model
  @configure 'Lightcurve', 'light_curve_url', \
  'source', 'priority', 'rel_start_time'
  
  constructor: ->
    super    
    @synthetic = true if @source.kind is "simulation"
    @planet = true if @source.kind is "planet"
          
module.exports = Lightcurve

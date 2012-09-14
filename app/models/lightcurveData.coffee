Spine = require('spine')

class LightcurveData extends Spine.Model
  @configure 'LightcurveData'
  
  constructor: (stuff) ->
    super    
    @data = stuff.data

    ymax = 0
    ymin = 1000000
    
    # Less preprocessing done here.
    i = 0
    while i < @data.length
      if @data[i].y > 0             
        point = @data[i]
        
        ymax = point.y if point.y > ymax
        ymin = point.y if point.y < ymin
      i++      
    
    @start = @data[0].x
    @end = @data[@data.length-1].x
    
    @yrange = ymax - ymin
    @ymax = ymax + 0.15 * @yrange
    @ymin = ymin - 0.15 * @yrange
    
#    console.log @ymin, @ymax, @data
          
module.exports = LightcurveData

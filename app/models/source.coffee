Spine = require('spine')

class Source extends Spine.Model
  @configure 'Source'
  
  constructor: ->
    super
    
    @synthetic = true if @kind is "simulation"
    @planet = true if @kind is "planet"
  
module.exports = Source

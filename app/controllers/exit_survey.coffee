Spine = require('spine')

Network = require 'lib/network'

class ExitSurvey extends Spine.Controller
  className: "textpage darkened"
  
  events:
    "click .big-button": "submitSurvey"
  
  constructor: ->
    super  

  active: ->
    super
    @render()
    
  render: =>
    @html require('views/exitsurvey')(@)  
    
  submitSurvey: ->
    # Validate results
    
    
    
    # Assemble into JSON and submit
    
    
module.exports = ExitSurvey

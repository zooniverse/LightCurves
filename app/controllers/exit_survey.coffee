Spine = require('spine')

class ExitSurvey extends Spine.Controller
  className: "textpage"
  
  constructor: ->
    super  

  active: ->
    super
    @render()
    
  render: =>
    @html require('views/exitsurvey')(@)  
    
module.exports = ExitSurvey

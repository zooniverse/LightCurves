Spine = require('spine')

Survey = require('models/survey')

Network = require 'lib/network'

class ExitSurvey extends Spine.Controller
  className: "textpage darkened"

  elements:
    "form": "form"
  
  events:
    "click .big-button": "submitSurvey"
  
  constructor: ->
    super  

  active: ->
    super
    @render()
    
  render: =>
    @html require('views/exitsurvey')(@)  
    
  submitSurvey: (ev) =>
    ev.preventDefault()
    
    # Validate results
    survey = Survey.fromForm(@form)

    console.log JSON.stringify(survey)

    if msg = survey.validate()
      return alert(msg)
    
    # Assemble into JSON and submit
    Network.submitExitSurvey JSON.stringify(survey)    
    
module.exports = ExitSurvey

Spine = require('spine')

Network = require 'lib/network'

class TaskRules extends Spine.Controller
  className: "textpage darkened"
  
  elements:
    "a.big-button": "button"
  
  events:
    "click .big-button": 'startClassifying'
  
  constructor: ->
    super
  
  active: ->
    super
    @render()
    
    @button.hide().delay(5000).fadeIn()
    
  render: ->
    @html require('views/task_rules')(@)
    
  startClassifying: (ev) ->
    ev.preventDefault()
    Network.startTasks()
    
module.exports = TaskRules

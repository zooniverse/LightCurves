Spine = require('spine')

Network = require 'lib/network'

class TaskRules extends Spine.Controller
  className: "textpage"
  
  events:
    "click .big-button": 'startClassifying'
  
  constructor: ->
    super
  
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/task_rules')(@)
    
  startClassifying: (ev) ->
    ev.preventDefault()
    Network.startTasks()
    
module.exports = TaskRules

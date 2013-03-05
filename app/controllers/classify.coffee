Spine = require('spine')

Dialog = require 'controllers/dialog'
Lightcurve = require 'models/lightcurve'
Viewer = require 'controllers/viewer'

Network = require 'lib/network'

class Classify extends Spine.Controller
  className: "lightcurve"
  
  events: 
    "click .dialog .button.finish": (ev) -> 
      ev.preventDefault()
      Network.finishTask()
  
  constructor: ->
    super
    @el.attr('id', 'classify')
    
    @dialog = new Dialog
    @viewer = new Viewer
      containerSelector: "#classify.lightcurve"
      dialog: @dialog
    @dialog.viewer = @viewer
            
  active: (params) ->
    super
    
    @dialog.active()
    @viewer.active()
    
    if params.zooniverse_id
      @zooniverse_id = params.zooniverse_id    
      @refresh()

  deactivate: ->
    super
    @viewer?.teardown()
  
  refresh: =>
    return unless @isActive() and @zooniverse_id
    
    @lightcurve = new Lightcurve(zooniverse_id: @zooniverse_id)
    @lightcurve.fetch @lcMetaLoaded, @lcDataLoaded    
  
  render: ->
    @html require('views/classify')(@)
    @append @dialog
    @append @viewer

    @viewer.render()
    @dialog.render()
    
    @dialog.editMode()
    @dialog.el.find(".step.classify").show()
  
  lcMetaLoaded: =>
    @render()
    
  lcDataLoaded: =>
    @viewer.loadData @lightcurve 
    
module.exports = Classify

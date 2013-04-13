Spine = require('spine')

Dialog = require 'controllers/dialog'
Lightcurve = require 'models/lightcurve'
Viewer = require 'controllers/viewer'

Network = require 'lib/network'

class Classify extends Spine.Controller
  className: "lightcurve"
  
  events: 
    "click .dialog .button.next": (ev) -> 
      ev.preventDefault()
      Network.finishTask()
    "click .finish_button .big-button": (ev) ->
      ev.preventDefault()
      Spine.trigger "showConfirm", 'Are you sure you want to take your current payment and submit?', ->
        Network.finishExp()
      Network.activity "Clicked Finish and Submit"
  
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
            
    # @dialog.active()
    # @viewer.active()
    
    if params.zooniverse_id
      @zooniverse_id = params.zooniverse_id    
      @refresh()    
      
  deactivate: ->
    super
    Network.setViewer(null)
    @viewer?.teardown()
  
  refresh: =>
    return unless @isActive() and @zooniverse_id
    
    @lightcurve = new Lightcurve(zooniverse_id: @zooniverse_id)
    @lightcurve.fetch @lcMetaLoaded, @lcDataLoaded    
  
  render: ->
    @html require('views/classify')(@)

    # Double append seems to be getting rid of events
    # Fixed via https://github.com/spine/spine/issues/444: sub-controllers use replace 
    
    @append @dialog.render()
    @append @viewer.render()

    # @viewer.render()
    # @dialog.render()    

    @dialog.editMode()
    @dialog.el.find(".step.classify").show()
  
  lcMetaLoaded: =>
    @render()
    
  lcDataLoaded: =>
    @viewer.loadData @lightcurve
    
    # On reload: can't draw annotations until viewer loads    
    Network.setViewer(@viewer)
    
module.exports = Classify

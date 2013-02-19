Spine = require('spine')

Dialog = require 'controllers/dialog'
Lightcurve = require 'models/lightcurve'
Viewer = require 'controllers/viewer'

TSClient = require 'turkserver-js-client'

class Classify extends Spine.Controller
  className: "lightcurve"
  
  constructor: ->
    super
    @el.attr('id', 'classify')
    
    @dialog = new Dialog
    @viewer = new Viewer
      containerSelector: "#classify.lightcurve"
      dialog: @dialog
            
  active: (params) ->
    super
    if params.zooniverse_id
      @zooniverse_id = params.zooniverse_id
      @refresh()
    else
      console.log TSClient.params
      TSClient.init "planethunters", ""
      console.log "test"

  deactivate: ->
    super
    @viewer?.teardown()
  
  refresh: =>
    return unless @isActive() and @zooniverse_id
    
    @lightcurve = new Lightcurve(zooniverse_id: @zooniverse_id)
    @lightcurve.fetch @lcMetaLoaded, @lcDataLoaded    
  
  render: ->
    @html require('views/classify')(@)
    @append @viewer
    @viewer.render()
  
  lcMetaLoaded: =>
    @render()
    
  lcDataLoaded: =>
    @viewer.loadData @lightcurve 
    
module.exports = Classify

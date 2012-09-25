Spine = require('spine')

LightcurveMeta = require 'models/lightcurveMeta'
LightcurveData = require 'models/lightcurveData'
Viewer = require 'controllers/viewer'

class Classify extends Spine.Controller
  className: "lightcurve"
  
  constructor: ->
    super
    @el.attr('id', 'classify')
    
    @viewer = new Viewer
      containerSelector: "#classify.lightcurve"

  active: (params) ->
    super
    @zooniverse_id = params.zooniverse_id
    @refresh()
    @render()    

  deactivate: ->
    super
    @viewer?.teardown()
  
  refresh: =>
    return unless @isActive() and @zooniverse_id    
    jqxhr = LightcurveMeta.loadWithProxy @zooniverse_id
                
    jqxhr.success @loadLCMeta
    jqxhr.error( -> alert "error getting proxied lightcurve json" ) # change to some error view  
  
  render: ->
    @html require('views/classify')(@)
    @append @viewer
    @viewer.render()
  
  loadLCMeta: (yql) =>
    unless yql.query.results
      alert("Failed to get metadata for " + @zooniverse_id)
      return      
      
    json = $.parseJSON(yql.query.results.body.p)
    @lightcurve = new LightcurveMeta(json.light_curve)        
    LightcurveData.loadData @lightcurve.light_curve_url, @loadLCData    
    
    @render()
    
  loadLCData: (json) =>
    @viewer.loadData(json, @lightcurve)
    
  round_float: (x, n) ->
    n = 0  unless parseInt(n)
    return false  unless parseFloat(x)
    Math.round(x * Math.pow(10, n)) / Math.pow(10, n)
    
module.exports = Classify

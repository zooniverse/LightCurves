Spine = require('spine')

Lightcurve = require 'models/lightcurve'

Viewer = require 'controllers/viewer'

# Tutorial controller
# Shows a bunch of features on the tutorial lightcurve
# then does a quick test for transits
class Tutorial extends Spine.Controller
  className: "lightcurve"

  elements:
    "#mag_glass": "mag_glass"
  
    ".dialog .stepIntro": "intro"
    ".dialog .stepDescribe": "describe"
    ".dialog .stepExample": "example"
    ".dialog .stepFalsePos": "falsePos"
    ".dialog .stepFlare": "flare"
    ".dialog .stepAnnotate": "annotate"
    ".dialog .stepShowTransits": "showTransits"
    ".dialog .stepShowGaps": "showGaps"
    ".dialog .stepZoomInst": "zoomInst"
    ".dialog .stepFinal": "final"

  events:
    "click .dialog .stepIntro .button": 'stepIntro'
    "click .dialog .stepDescribe .button": 'stepDescribe'
    "click .dialog .stepExample .button": 'stepExample'
    "click .dialog .stepFalsePos .button": 'stepFalsePos'
    "click .dialog .stepFlare .button": 'stepFlare'
    "click .dialog .stepAnnotate .finish": 'stepAnnotate'
    "click .dialog .stepShowTransits .button": 'stepShowTransits'
    "click .dialog .stepShowGaps .button": 'stepShowGaps'
    "click .dialog .stepZoomInst .button": 'stepZoomInst'
    "click .dialog .stepFinal .finish": 'stepFinal'

  constructor: ->
    super
    @el.attr('id', 'tutorial')
    
    @viewer = new Viewer
      containerSelector: "#tutorial.lightcurve"
      allow_annotations: false

  active: (params) ->
    super
    @refresh()

  deactivate: ->
    super
    @viewer?.teardown()
  
  refresh: =>
    return unless @isActive()
    
    @lightcurve = Lightcurve.tutorialLightcurve()
    
    @lightcurve.fetch @lcMetaLoaded, @lcDataLoaded    
  
  render: ->
    @html require('views/tutorial')(@)
    @append @viewer
    @viewer.render()
    
    @workflow_container = @el.find(".dialog .workflow")
    
    @workflow_container.find(".stepIntro").fadeIn('fast')
  
  lcMetaLoaded: =>
    @render()
    
  lcDataLoaded: =>
    @viewer.loadData @lightcurve
    
  nextStep: (ev, element) ->
    ev.preventDefault()
    $(ev.target).closest('.step').fadeOut(-> element.fadeIn())
    
  stepIntro: (ev) ->     
    @nextStep ev, @describe    

  stepDescribe: (ev) -> 
    @nextStep ev, @example
    @viewer.animateZoom [11.2, 14.6]
    @mag_glass.show()
    .html(t('workflows.tutorial.workflow.questions.in_planet_hunters'))
    .animate
      top: 150
      left: 300,
      1000

  stepExample: (ev) -> 
    @nextStep ev, @falsePos
    @viewer.animateZoom [9.6, 13.2]
    @mag_glass.show()
    .html("This is probably not a transit, and just a measurement error")
    .animate
      top: 150
      left: 280,
      1000

  stepFalsePos: (ev) -> 
    @nextStep ev, @flare
    @viewer.animateZoom [3, 10]
    @mag_glass.show()
    .html("Don't mistake these solar flares for transits!")
    .animate
      top: -50
      left: 290,
      1000
  
  stepFlare: (ev) ->
    @nextStep ev, @showGaps
    @viewer.animateZoom [17.4, 24.2]
    @mag_glass.show()
    .html(t('workflows.tutorial.workflow.questions.gaps_tooltip'))
    .animate
      top: 100
      left: 290,
      1000

  stepShowGaps: (ev) -> 
    @nextStep ev, @zoomInst
    @viewer.animateZoom [0, 35]
    @mag_glass.hide()

  stepZoomInst: (ev) -> 
    @nextStep ev, @annotate
    @viewer.animateZoom [0, 35]
    @viewer.allow_annotations = true
    
  stepAnnotate: (ev) -> 
    @nextStep ev, @showTransits
    @viewer.animateZoom [0, 35]
    @viewer.show_simulations = true
    @viewer.graph_zoom()
    
  stepShowTransits: (ev) -> 
    @nextStep ev, @final
        
  stepFinal: (ev) -> 
    ev.preventDefault()
    alert 'done'
    
module.exports = Tutorial

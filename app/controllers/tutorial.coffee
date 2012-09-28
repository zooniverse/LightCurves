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
    ".dialog .stepExposition": "exposition"
    ".dialog .stepDescribe": "describe"
    ".dialog .stepExample": "example"
    ".dialog .stepExampleZoom": "exampleZoom"
    ".dialog .stepFalsePos": "falsePos"
    ".dialog .stepFlare": "flare"
    ".dialog .stepShowGaps": "showGaps"
    ".dialog .stepZoomInst": "zoomInst"
    ".dialog .stepAnnotate": "annotate"
    ".dialog .stepAnnotateCont": "annotateCont"
    ".dialog .stepShowTransits": "showTransits"
    ".dialog .stepFinal": "final"

  events:
    "click .dialog .stepIntro .button": 'finishIntro'
    "click .dialog .stepExposition .button": 'finishExposition'
    "click .dialog .stepDescribe .button": 'finishDescribe'
    "click .dialog .stepExample .button": 'finishExample'
    "click .dialog .stepExampleZoom .button": 'finishExampleZoom'
    "click .dialog .stepFalsePos .button": 'finishFalsePos'
    "click .dialog .stepFlare .button": 'finishFlare'
    "click .dialog .stepShowGaps .button": 'finishShowGaps'
    "click .dialog .stepZoomInst .button": 'finishZoomInst'
#    "click .dialog .stepAnnotate .finish": 'finishAnnotate'
    "click .dialog .stepAnnotateCont .finish": 'finishAnnotateCont'
    "click .dialog .stepShowTransits .button": 'finishShowTransits'
    "click .dialog .stepFinal .finish": 'finishFinal'

  constructor: ->
    super
    @el.attr('id', 'tutorial')
    
    @viewer = new Viewer
      containerSelector: "#tutorial.lightcurve"
      allow_annotations: false
      allow_zoom: false
      addTransitCallback: => @finishAnnotate()

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
    ev.preventDefault?()
    $(ev.target || ev).closest('.step').fadeOut(-> element.fadeIn())
    
  finishIntro: (ev) ->     
    @nextStep ev, @exposition    

  finishExposition: (ev) ->     
    @nextStep ev, @describe    

  finishDescribe: (ev) -> 
    @nextStep ev, @example
    
    @mag_glass.show()
    .html(t('workflows.tutorial.workflow.questions.in_planet_hunters'))
    .animate
      top: 160
      left: 215,
      1000

  finishExample: (ev) -> 
    @nextStep ev, @exampleZoom
    
    @viewer.animateZoom [11.6, 15.1]
    @mag_glass.show()
    .html('A transit shows up as a sequence of low dots when you zoom in')
    .animate
      top: 150
      left: 215,
      1000

  finishExampleZoom: (ev) -> 
    @nextStep ev, @falsePos
    
    @viewer.animateZoom [9.6, 13.2]
    @mag_glass.show()
    .html("This is probably not a transit, and just a measurement error")
    .animate
      top: 150
      left: 280,
      1000

  finishFalsePos: (ev) -> 
    @nextStep ev, @flare
    
    @viewer.animateZoom [3, 10]
    @mag_glass.show()
    .html("Don't mistake these solar flares for transits!")
    .animate
      top: -50
      left: 285,
      1000
  
  finishFlare: (ev) ->
    @nextStep ev, @showGaps
    
    @viewer.animateZoom [17.4, 24.2]
    @mag_glass.show()
    .html(t('workflows.tutorial.workflow.questions.gaps_tooltip'))
    .animate
      top: 100
      left: 290,
      1000

  finishShowGaps: (ev) -> 
    @nextStep ev, @zoomInst
    
    @mag_glass.hide()
    @viewer.animateZoom [0, 35]
    @viewer.setZoomEnabled true
    @viewer.show_tooltips()

  finishZoomInst: (ev) -> 
    @nextStep ev, @annotate
    
    @viewer.animateZoom [0, 35]
    @viewer.allow_annotations = true
    
  finishAnnotate: (ev) -> 
    @nextStep @annotate, @annotateCont
  
  finishAnnotateCont: (ev) ->  
    @nextStep ev, @showTransits
    
    @viewer.animateZoom [0, 35]
    @viewer.show_simulations = true
    @viewer.redraw()
    
  finishShowTransits: (ev) -> 
    @nextStep ev, @final
        
  finishFinal: (ev) -> 
    ev.preventDefault()
    @navigate '/classify', 'APH10154043'
    
module.exports = Tutorial

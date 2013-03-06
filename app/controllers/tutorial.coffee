Spine = require('spine')

Dialog = require 'controllers/dialog'
Viewer = require 'controllers/viewer'

Lightcurve = require 'models/lightcurve'

Network = require 'lib/network'

# Tutorial controller
# Shows a bunch of features on the tutorial lightcurve
# then does a quick test for transits
class Tutorial extends Spine.Controller
  className: "lightcurve"

  elements:
    "#mag_glass": "mag_glass"
    
    ".dialog .button.prev": "buttonPrev"
    ".dialog .button.next": "buttonNext"

  events:    
    "click .dialog .button.prev": 'clickPrev'
    "click .dialog .button.next": 'clickNext'
    "click .dialog .button.finish": 'clickFinish'

  constructor: ->
    super
    @el.attr('id', 'tutorial')
    
    @stepIndex = 0
    
    @dialog = new Dialog
      tutorial: true
    @viewer = new Viewer
      containerSelector: "#tutorial.lightcurve"
      allow_annotations: false
      allow_zoom: false
      dialog: @dialog
      addTransitCallback: => @clickNext() if @steps[@stepIndex][0] is 'stepAnnotate'
    @dialog.viewer = @viewer      

    @steps = [
      ['stepIntro', @intro],
      ['stepExposition', @exposition],
      ['stepDescribe', @describe],
      ['stepExample', @example],
      ['stepExampleZoom', @exampleZoom],
      ['stepFalsePos', @falsePos],
      ['stepFlare', @flare],
      ['stepShowGaps', @showGaps],
      ['stepZoomInst', @zoomInst],
      ['stepAnnotate', @annotate],
      ['stepAnnotateCont', @annotateCont],
      ['stepShowTransits', @showTransits],
      ['stepFinal', @final]
    ] 

  active: (params) ->
    super
    @refresh()
            
    @dialog.active()
    @viewer.active()    
    Network.startTutorial()

  deactivate: ->
    super
    @viewer?.teardown()
  
  refresh: =>
    return unless @isActive()
    
    @lightcurve = Lightcurve.tutorialLightcurve()
    
    @lightcurve.fetch @lcMetaLoaded, @lcDataLoaded    
  
  render: ->
    @html require('views/tutorial')(@)
    @append @dialog
    @append @viewer
    
    @viewer.render()
    @dialog.render()
    
    @showStep()
  
  lcMetaLoaded: =>
    @render()
    
  lcDataLoaded: =>
    @viewer.loadData @lightcurve
  
  teardownStep: ->
    stepclass = @steps[@stepIndex][0]
    
    @dialog.el.find(".workflow .#{stepclass}").hide()
    # .fadeOut(-> element.fadeIn())    
  
  showStep: -> 
    stepclass = @steps[@stepIndex][0]
    
    @dialog.el.find(".workflow .#{stepclass}").fadeIn('fast')
    @steps[@stepIndex][1]?()
    
  clickPrev: (ev, element) ->
    ev?.preventDefault()
    @teardownStep()
    @stepIndex -= 1
    @showStep()    
    
  clickNext: (ev, element) ->
    ev?.preventDefault()
    @teardownStep()
    @stepIndex += 1
    @showStep()
    
  clickFinish: (ev, element) ->
    ev?.preventDefault()
    if @stepIndex < @steps.length - 1
      @clickNext()
    else
      Network.finishTutorial()
    
  intro: =>     

  exposition: =>     

  describe: =>
    @mag_glass.hide() 

  example: => 
    @viewer.animateZoom [0, 35]
    @mag_glass.show()
    .html(t('workflows.tutorial.workflow.questions.in_planet_hunters'))
    .animate
      top: 160
      left: 215,
      1000
    
  exampleZoom: => 
    @viewer.animateZoom [11.6, 15.1]
    @mag_glass.show()
    .html('A transit shows up as a sequence of low dots when you zoom in')
    .animate
      top: 150
      left: 215,
      1000    

  falsePos: => 
    @viewer.animateZoom [9.6, 13.2]
    @mag_glass.show()
    .html("This is probably not a transit, and just a measurement error")
    .animate
      top: 150
      left: 280,
      1000
      
  flare: =>
    @viewer.animateZoom [3, 10]
    @mag_glass.show()
    .html("Don't mistake these solar flares for transits!")
    .animate
      top: -50
      left: 285,
      1000
    
  showGaps: => 
    @viewer.animateZoom [17.4, 24.2]
    @mag_glass.show()
    .html(t('workflows.tutorial.workflow.questions.gaps_tooltip'))
    .animate
      top: 100
      left: 290,
      1000    
    
    @viewer.setZoomEnabled false    
    
  zoomInst: =>     
    @mag_glass.hide()
    @viewer.animateZoom [0, 35]
    @viewer.setZoomEnabled true
    @viewer.show_tooltips()
    @viewer.allow_annotations = false
    
    @dialog.backNextMode()
        
  annotate: =>     
    @viewer.animateZoom [0, 35]
    @viewer.allow_annotations = true
        
    @dialog.backOnlyMode()

  annotateCont: =>  
    @viewer.show_simulations = false
    @viewer.redraw()
    
    @dialog.editMode()
        
  showTransits: => 
    @viewer.animateZoom [0, 35]
    @viewer.show_simulations = true
    @viewer.redraw()
    
    @dialog.backNextMode()
        
  final: => 
    @dialog.backFinishMode()
    
module.exports = Tutorial

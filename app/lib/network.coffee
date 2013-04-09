TSClient = require 'turkserver-js-client'
Codec = require 'turkserver-js-client/src/codec'

Spine = require 'spine'

###
Network interface for lightcurve classification

Replace this file to talk to Zooniverse, etc 
###
class Network

  @serverport = null
  @tutorial = false
  @viewer = null
  @payment = null
  
  # After how long to display a warning
  @inactiveWarningMillis = 120000  

  @init: (payment) ->
    if not TSClient.params.assignmentId
      console.log "no parameters; ignoring network"
      @serverport = window.location.hostname + ':' + '9876'
      TSClient.initLocal()
      return

    # NOTE: all navigates below happen in response to messages

    TSClient.QuizRequired ->
      Spine.Route.navigate("/")
    
    TSClient.StartExperiment ->
      Spine.Route.navigate("/taskrules")

    TSClient.BroadcastMessage (data) =>
      if data.error
        Spine.trigger "showMessage", data.error
          
      if data.task
        # Don't update hash fragment here
        Spine.Route.navigate "/classify", data.task
        
      if "payment" of data
        @payment.el.show()
        @payment.updatePay(data)
        
      if data.annotations        
        if @viewer is null
          # hang on to these until viewer is ready
          console.log "waiting for viewer to load"
          @annotations = data.annotations          
        else    
          console.log "redrawing annotations"
          @viewer.addTransitExternal(ann) for ann in data.annotations
          @viewer.redraw_transits()
          
        # start inactivity monitor on a reload
        TSClient.startInactivityMonitor(@checkInactivity)

    TSClient.FinishExperiment ->     
      Spine.Route.navigate("/exitsurvey")
      TSClient.stopInactivityMonitor()

    TSClient.ErrorMessage (status, msg) ->
      switch status
        when Codec.status_completed, Codec.status_expfinished
          Spine.Route.navigate "/exitsurvey"          
        else
          Spine.Route.navigate "/error", msg
          
      Spine.trigger("showMessage", msg) if msg
  
    # hide payment initially
    payment.el.hide()
    @payment = payment
    
    @serverport = window.location.hostname + ':' + TSClient.params.port
    TSClient.init "planethunters", ""
  
  @setViewer: (viewer) =>
    if viewer and @annotations
      viewer.addTransitExternal(ann) for ann in @annotations
      viewer.redraw_transits()
      @annotations = null
          
    @viewer = viewer    
  
  @startTutorial: ->
    @tutorial = true
  
  @startTasks: ->
    msg =
      action: "starttasks"
    TSClient.sendExperimentBroadcast(msg)
    
    TSClient.startInactivityMonitor(@checkInactivity)    
  
  @activity: (description) ->
    TSClient.sendExperimentBroadcast
      action: "activity"
      type: description
  
    TSClient.resetInactivity()
    
    # For when modal dialog is closed
    @warningShown = false
  
  @addTransit: (transit) ->
    console.log "added "
    console.log transit
    return if @tutorial
    
    msg = 
      action: "addannotation"
    $.extend(msg, transit)
    TSClient.sendExperimentBroadcast(msg)

    TSClient.resetInactivity()

  @editTransit: (transit) ->
    console.log "resized "
    console.log transit
    return if @tutorial
    
    msg = 
      action: "editannotation"
    $.extend(msg, transit)
    TSClient.sendExperimentBroadcast(msg)
    
    TSClient.resetInactivity()

  @removeTransit: (transit) ->
    console.log "removed "
    console.log transit
    return if @tutorial
    
    msg = 
      action: "removeannotation"
    $.extend(msg, transit)
    TSClient.sendExperimentBroadcast(msg)

    TSClient.resetInactivity()
  
  @finishTutorial: ->
    console.log "tutorial done"
    @tutorial = false
    
    if TSClient.hitIsViewing()
      Spine.trigger("showMessage", "This is a preview. Please accept the HIT to do the task.")
    else
      TSClient.sendQuizResults 1, 1, ""      
      
    # fake finish tutorial      
    Spine.Route.navigate '/classify', 'APH10154043' if TSClient.localMode
    
  @finishTask: ->
    console.log "finish"
    msg = 
      action: "finishtask"
    TSClient.sendExperimentBroadcast(msg)
    
    TSClient.resetInactivity()
  
  @finishExp: ->
    console.log "all done"
    TSClient.sendExperimentBroadcast
      action: "finishexp"
      
    TSClient.stopInactivityMonitor()
  
  @submitExitSurvey: (data) ->
    console.log "submitting survey"
    TSClient.submitHIT data                  
  
  @resetInactivity: ->
    TSClient.resetInactivity()
    
  @checkInactivity: (inactiveTime) =>        
    if inactiveTime > @inactiveWarningMillis and not @warningShown              
      @warningShown = true
      
      # Don't reset inactivity for this, duh
      TSClient.sendExperimentBroadcast
        action: "activity"
        type: "Inactivity warning shown"

      # Display inactivity warning
      Spine.trigger "showMessage", "Are you still there? Your session will end automatically if you do nothing for one minute."
      
      # console.log "Inactive for " + inactiveTime

module.exports = Network

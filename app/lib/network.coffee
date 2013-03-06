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

  @init: (payment, viewer) ->
    if not TSClient.params.assignmentId
      console.log "no parameters; ignoring network"
      @serverport = window.location.hostname + ':' + '8080'
      TSClient.initLocal()
      return

    # NOTE: all navigates below happen in response to messages

    TSClient.QuizRequired ->
      Spine.Route.navigate("/")

    TSClient.BroadcastMessage (data) =>      
      if data.task
        Spine.Route.navigate("/classify/" + data.task)
        
      if data.payment
        payment.updatePay(data.payment)
        
      if data.annotations        
        if @viewer is null
          # hang on to these until viewer is ready
          console.log "waiting for viewer to load"
          @annotations = data.annotations          
        else    
          console.log "redrawing annotations"
          @viewer.addTransitExternal(ann) for ann in data.annotations
          @viewer.redraw_transits()

    TSClient.FinishExperiment -> Spine.Route.navigate("/exitsurvey")

    TSClient.ErrorMessage (status, msg) ->
      alert(msg)
      switch status
        when Codec.status_completed
          Spine.Route.navigate "/exitsurvey"      

    @serverport = window.location.hostname + ':' + TSClient.params.port
    console.log "trying network"    
    TSClient.init "planethunters", ""
  
  @setViewer: (viewer) =>
    if viewer and @annotations
      viewer.addTransitExternal(ann) for ann in @annotations
      viewer.redraw_transits()
      @annotations = null
    
    console.log "viewer set"  
    @viewer = viewer    
  
  @startTutorial: ->
    @tutorial = true    
    
  @addTransit: (transit) ->
    console.log "added "
    console.log transit
    return if @tutorial
    
    msg = 
      action: "addannotation"
    $.extend(msg, transit)
    TSClient.sendExperimentBroadcast(msg)

    @resetInactivity()

  @editTransit: (transit) ->
    console.log "resized "
    console.log transit
    return if @tutorial
    
    msg = 
      action: "editannotation"
    $.extend(msg, transit)
    TSClient.sendExperimentBroadcast(msg)
    
    @resetInactivity()

  @removeTransit: (transit) ->
    console.log "removed "
    console.log transit
    return if @tutorial
    
    msg = 
      action: "removeannotation"
    $.extend(msg, transit)
    TSClient.sendExperimentBroadcast(msg)

    @resetInactivity()
  
  @finishTutorial: ->
    console.log "tutorial done"
    @tutorial = false
    TSClient.sendQuizResults 1, 1, ""      
    # fake finish tutorial
    Spine.Route.navigate '/classify', 'APH10154043' if TSClient.localMode
    
  @finishTask: ->
    console.log "finish"
    msg = 
      action: "finishtask"
    TSClient.sendExperimentBroadcast(msg)
    
  @resetInactivity: ->
    @lastInactive = Date.now()
    

module.exports = Network

TSClient = require 'turkserver-js-client'

###
Network interface for lightcurve classification

Replace this file to talk to Zooniverse, etc 
###
class Network

  @serverport = null

  @init: (payment) ->
    if not TSClient.params.assignmentId
      console.log "no parameters; ignoring network"
      @serverport = window.location.hostname + ':' + '8080'
      TSClient.initLocal()
      return

    TSClient.BroadcastMessage (data) ->      
      if data.task
        Spine.Route.navigate "/classify/" + data.task
      if data.payment
        payment.updatePay(data.payment)
    
    TSClient.FinishExperiment -> Spine.Route.navigate("/exitsurvey")

    @serverport = window.location.hostname + ':' + TSClient.params.port
    console.log "trying network"    
    TSClient.init "planethunters", ""
    
  @addTransit: (transit) ->
    console.log "added "
    console.log transit

    msg = 
      action: "addannotation"
    $.extend(msg, transit)
    TSClient.sendExperimentBroadcast(msg)

    @resetInactivity()

  @editTransit: (transit) ->
    console.log "resized "
    console.log transit

    msg = 
      action: "editannotation"
    $.extend(msg, transit)
    TSClient.sendExperimentBroadcast(msg)
    
    @resetInactivity()

  @removeTransit: (transit) ->
    console.log "removed "
    console.log transit
    
    msg = 
      action: "removeannotation"
    $.extend(msg, transit)
    TSClient.sendExperimentBroadcast(msg)

    @resetInactivity()
    
  @finishTask: ->
    console.log "finish"
    msg = 
      action: "finishtask"
    TSClient.sendExperimentBroadcast(msg)
    
  @resetInactivity: ->
    @lastInactive = Date.now()
    

module.exports = Network

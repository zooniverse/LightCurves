Spine = require('spine')

class Dialog extends Spine.Controller
  className: "dialog"

  elements:
    ".workflow": "workflowContainer"
    ".actions.edit": "editActions"
    ".button.prev": "prevButton"
    ".button.next": "nextButton"
    ".button.finish": "finishButton"

  constructor: ->
    super    
    @tutorial ?= false    
    
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/dialog')(@)          
    @workflowContainer.prepend(require('views/tutorial_steps')) if @tutorial    
    @backNextMode()
    
  hideButtons: ->  
    @editActions.hide()
    @prevButton.hide()
    @nextButton.hide()
    @finishButton.hide()
    
  backNextMode: ->
    @editActions.hide()
    @prevButton.show()
    @nextButton.show()
    @finishButton.hide()

  backFinishMode: ->
    @editActions.hide()
    @prevButton.show()
    @nextButton.hide()
    @finishButton.show()
  
  editMode: ->
    @editActions.show()
    @prevButton.hide()
    @nextButton.hide()
    @finishButton.show()        
    
module.exports = Dialog

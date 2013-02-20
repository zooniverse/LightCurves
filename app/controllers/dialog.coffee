Spine = require('spine')

class Dialog extends Spine.Controller
  className: "dialog"

  elements:
    ".workflow": "workflowContainer"
    ".actions .edit": "editActions"
    ".button.prev": "prevButton"
    ".button.next": "nextButton"
    ".button.finish": "finishButton"

  events:
    "click .button.transit": "focusTransit"
    "click .button.transit .delete": "removeTransit"

  constructor: ->
    super    
    @tutorial ?= false    
    @viewer ?= undefined # set after constructing
    
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/dialog')(@)          
    @workflowContainer.prepend(require('views/tutorial_steps')) if @tutorial    
    @backNextMode()
    
  addTransit: (number) ->
    button = @editActions.find(".transit:first-child")
      .clone()
      .attr("title", number)
      .text(number)
      .css("display", "inline-block")
    .append(
      $("<a/>",
        class: "delete"
        href: "#"
        title: "delete"
      ))
    
    # insert this button in the list
    # TODO: broken when a higher number is in the list
    existing = @editActions.find(".transit[title=#{number+1}]")
    if existing.length > 0 
      existing.before button
    else
      @editActions.append button
  
  focusTransit: (ev) =>
    ev.preventDefault()
    button = $(ev.target)
    number = button.attr("title")
    @viewer?.focusTransit(number)
    @highlightTransit button
  
  highlightButton: (number) -> 
    button = @editActions.find(".transit[title=#{number}]")
    @highlightTransit button
    
  highlightTransit: (button) ->
    # Remove old focus and find new one. TODO make this more Spine-y.
    @editActions.find(".transit").removeClass("focus")
    .find(".delete").fadeOut()
    
    button.addClass("focus")
    .find(".delete").fadeIn()
  
  removeTransit: (ev) =>
     ev.preventDefault()
     button = $(ev.target).parent()
     number = button.attr("title")
     @viewer?.removeTransit number
     
     button.fadeOut -> button.remove()
    
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

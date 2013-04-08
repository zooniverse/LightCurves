Spine = require('spine')

class Survey extends Spine.Model

  @configure 'Survey', 'enjoyable', 'difficulty', 'payment', 'precision', 'recall', \
    'strategyComments', 'engagementComments', 'uiComments', 'bugComments'
    
  validate: ->
    arr = []
    unless @enjoyable
      arr.push "Please choose an option for how enjoyable the task was."
    unless @difficulty
      arr.push "Please choose an option for how difficult the task was."
    unless @payment
      arr.push "Please choose an option for how likely you are to do the task again if you were paid the same way."
    unless @precision
      arr.push "Please specify how many of the transits you marked you think were correct."
    unless @recall
      arr.push "Please specify how many of all planet transits you think you spotted."
    
    unless @strategyComments
      arr.push "Please explain how you searched for planet transits."
    unless @engagementComments
      arr.push "Please explain how you decided to stop working on the task."
    unless @uiComments
      arr.push "Please comment on the tutorial and interface."
    
    arr.join "<br>"
      
module.exports = Survey

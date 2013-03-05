Spine = require('spine')

Home = require 'controllers/home'
Tutorial = require 'controllers/tutorial'
Classify = require 'controllers/classify'
Sources = require 'controllers/sources'
ExitSurvey = require 'controllers/exit_survey'

Payment = require 'controllers/payment'

class Main extends Spine.Stack
  className: "main stack"

  constructor: ->
    super
    # remove browser warning
    $(@el).children("h3").remove()

  controllers:
    home: Home
    tutorial: Tutorial
    classify: Classify
    sources: Sources
    exitsurvey: ExitSurvey
    
  default: 'home'
    
  routes:
    '/': 'home'
    '/tutorial': 'tutorial'
    '/classify': 'classify'
    '/classify/:zooniverse_id': 'classify'
    '/sources/:zooniverse_id': 'sources'
    '/exitsurvey': 'exitsurvey'
    
module.exports = Main

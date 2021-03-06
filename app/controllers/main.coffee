Spine = require('spine')

Home = require 'controllers/home'
Tutorial = require 'controllers/tutorial'
Classify = require 'controllers/classify'
Sources = require 'controllers/sources'
TaskRules = require 'controllers/task_rules'
ExitSurvey = require 'controllers/exit_survey'
Error = require 'controllers/error'

Payment = require 'controllers/payment'

class Main extends Spine.Stack
  className: "main stack"

  constructor: ->
    super

  controllers:
    home: Home
    tutorial: Tutorial
    classify: Classify
    sources: Sources
    taskrules: TaskRules
    exitsurvey: ExitSurvey
    error: Error
    
  default: 'home'
    
  routes:
    '/': 'home'
    '/tutorial': 'tutorial'
    '/classify': 'classify'
    '/classify/:zooniverse_id': 'classify'
    '/sources/:zooniverse_id': 'sources'
    '/taskrules': 'taskrules'
    '/exitsurvey': 'exitsurvey'
    '/error/:msg': 'error'
    
module.exports = Main

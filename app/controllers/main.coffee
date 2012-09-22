Spine = require('spine')

Home = require 'controllers/home'
Classify = require 'controllers/classify'
Sources = require 'controllers/sources'

class Main extends Spine.Stack
  el: "#content"  
  className: "main stack"

  constructor: ->
    # remove browser warnings before calling super
    $(@el).empty()
    super

  controllers:
    home: Home
    classify: Classify
    sources: Sources
    
  default: 'home'
    
  routes:
    '/': 'home'
    '/classify/:zooniverse_id': 'classify'
    '/sources/:zooniverse_id': 'sources'
    
module.exports = Main

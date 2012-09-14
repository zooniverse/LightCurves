Spine = require('spine')

Home = require 'controllers/home'
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
    sources: Sources
    
  default: 'home'
    
  routes:
    '/': 'home'
    '/sources/:zooniverse_id': 'sources'
    
module.exports = Main

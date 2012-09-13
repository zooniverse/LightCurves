Spine = require('spine')

Home = require 'controllers/home'
Sources = require 'controllers/sources'

class Main extends Spine.Stack
  el: "#carrousel"  
  className: "main stack"

  constructor: ->
    super

  controllers:
    home: Home
    sources: Sources
    
  default: 'home'
    
  routes:
    '/': 'home'
    '/sources/:zooniverse_id': 'sources'
    
module.exports = Main

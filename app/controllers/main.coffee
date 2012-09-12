Spine = require('spine')

Sources = require('controllers/sources')

class Main extends Spine.Stack
  el: "#main"

  controllers:
    sources: Sources
    
  default: 'sources'
    
  routes:
    '/sources/:id': 'sources'
    
module.exports = Main

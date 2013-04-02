Spine = require('spine')

class Error extends Spine.Controller
  constructor: ->
    super

  active: (params) ->
    super
    @msg = params.msg
    @render()
    
  render: ->
    @html require('views/error')(@)
    
module.exports = Error

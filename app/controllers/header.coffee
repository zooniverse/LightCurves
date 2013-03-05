Spine = require('spine')

Payment = require('controllers/payment')

class Header extends Spine.Controller
  constructor: ->
    super
    @payment = new Payment    
    
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/header')
    @append @payment
    @payment.render()
    
module.exports = Header

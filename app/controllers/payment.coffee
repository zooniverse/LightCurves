Spine = require('spine')

class Payment extends Spine.Controller
  className: "payment"
  
  elements:
    ".payment-amount strong": "paymentAmount"
  
  constructor: ->
    super
    @startTime = new Date().getTime()
    
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/payment')
    
  updatePay: =>
    currentTime = new Date().getTime()
    
    @paymentAmount.html( Util.round_float((currentTime - @startTime) / 1000 / 60 * 0.1, 2) )
    
    
module.exports = Payment

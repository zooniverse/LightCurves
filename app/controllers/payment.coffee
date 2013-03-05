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
    
  updatePay: (amount) =>    
    @paymentAmount.html( Util.round_float(amount, 2) )    
    
module.exports = Payment

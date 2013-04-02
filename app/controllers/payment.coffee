Spine = require('spine')

class Payment extends Spine.Controller
  className: "payment"
  
  elements:
    ".payment-method": "paymentMethod"
    ".payment-increment": "paymentIncrement"
    ".payment-amount strong": "paymentAmount"
  
  constructor: ->
    super
    
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/payment')
    
  updatePay: (data) =>
    @paymentMethod.html data.paymentterms
    @paymentIncrement.html data.paymentincr
    @paymentAmount.html( data.payment.toFixed(2) )    
    
module.exports = Payment

require = window.require

describe 'Payment', ->
  Payment = require('controllers/payment')
  
  it 'can noop', ->
    
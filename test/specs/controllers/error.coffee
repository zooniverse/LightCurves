require = window.require

describe 'Error', ->
  Error = require('controllers/error')
  
  it 'can noop', ->
    
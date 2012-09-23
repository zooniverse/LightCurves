require('json2ify')
require('es5-shimify')
require('jqueryify')

require('spine')
require('spine/lib/local')
require('spine/lib/ajax')
require('spine/lib/manager')
require('spine/lib/route')

require 'lib/jquery.jsonp-2.4.0.min'

# Something is wrong with d3, we just take the js file
require 'd3/d3.v2'
#require 'd3'

# Temporary hack for getting EN strings.
require 'lib/en'
require 'lib/simple_trans'


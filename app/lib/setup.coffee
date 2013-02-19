require('json2ify')
require('es5-shimify')
require('jqueryify')

require('spine')
require('spine/lib/local')
require('spine/lib/ajax')
require('spine/lib/manager')
require('spine/lib/route')

require 'd3/d3.v2'

###
Other stuff not in NPM...
###
require 'lib/jquery.jsonp-2.4.0.min'

# Temporary hack for getting EN strings.
require 'lib/en'
require 'lib/simple_trans'

# For more responsiveness in laggy browsers (I'm looking at you, Firefox!)
# FIXME: This causes IE to use the fallback, which is sub-optimal
require 'lib/animframe'

window.Util = require 'lib/util'


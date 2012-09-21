Spine = require('spine')

LightcurveData = require 'models/lightcurveData'
LightcurveMeta = require 'models/lightcurveMeta'

class Viewer extends Spine.Controller
  
  elements:
    '#zoom': 'zoomBtn'
    
  events:
    'click #zoom a': 'zoom'
    'mouseenter #zoom a': -> $("#yZoom_help").show()
    'mouseleave #zoom a': -> $("#yZoom_help").delay(1600).fadeOut 1600
  
  constructor: ->
    super
    @el.attr("id", "graph")

    # Copied variables from stylus, fix in future
    @left_margin = 50
    @top_padding = 5
    
    @width = 670
    @height = 450
    @h_graph = 400
    @h_bottom = 30
    
    @h_to_context = @top_padding + @height - @h_bottom
      
    @max_zoom = 10
    
    @n_xticks = 10
    @n_yticks = 6
    @n_contextticks = 7
      
    # Add spinner in future  
    @loading = false
  
  teardown: -> # Clean things up 
    
  render: =>    
    @html require('views/lightcurve')(@)          
  
  zoom: (ev) ->
    ev.preventDefault()
    alert "click"
    # do stuff
  
  loadData: (json, meta) =>
    alert(t('lightcurve.problem')) if not json or json.length <= 0
    
    @lcData = new LightcurveData(data: json)
    
    # Scale for focus area.
    @x_scale = d3.scale.linear() 
      .domain([@lcData.start, @lcData.end])
      .range([0, @width])    
    @y_scale = d3.scale.linear()
      .domain([@lcData.ymin, @lcData.ymax])
      .range([@h_graph, 0])
  
    # Scale for bottom area.
    @x_bottom = d3.scale.linear()
      .domain([@lcData.start, @lcData.end])
      .range([0, @width])
    @y_bottom = d3.scale.linear()
      .domain([@lcData.ymin, @lcData.ymax])
      .range([@h_bottom, 0])
          
    @zoom_graph = d3.behavior.zoom()
      .x(@x_scale)
      .scaleExtent([1, @max_zoom])
      .on("zoom", @graph_zoom)
    
    # Chart axes, ticks, and labels
    @xAxis = d3.svg.axis()
      .orient("bottom")
      .scale(@x_scale)
      .ticks(@n_xticks)
      .tickSize(-@h_graph, 0, 0)
    
    @yAxis = d3.svg.axis()
      .orient("left")
      .scale(@y_scale)
      .ticks(@n_yticks)
      .tickSize(-@width, 0, 0)

    @svg = d3.select("#graph_svg")
      .attr("width", @width + @left_margin)
      .attr("height", @height + @top_padding + 20)

    @svg_xaxis = @svg.append("g")
      .attr("class", "chart-xaxis")
      .attr("transform", "translate(" + @left_margin + "," + (@top_padding + @h_graph) + ")")
    
    @svg_yaxis = @svg.append("g")
      .attr("class", "chart-yaxis")
      .attr("transform", "translate(" + @left_margin + "," + @top_padding + ")")

    # Size canvas and position at right spot relative to SVG
    @canvas = d3.select("#graph_canvas")   
      .attr("width", @width)
      .attr("height", @h_graph)
      .call(@zoom_graph)
      .node().getContext("2d")        
  
    # Bottom line graph, axes, ticks, and labels
    @lcLine = d3.svg.line()
      .x( (d) -> @x_bottom(d.x) )
      .y( (d) -> @y_bottom(d.y) )
        
    @bottom = @svg.append("g")
      .attr("class", "context")
      .attr("transform", "translate(" + @left_margin + "," + @h_to_context + ")")           
      .call(@zoom_graph) # Enable zoom actions on here too!            
    @bottom.append("svg:path").attr("d", @lcLine(@lcData.data))
    
    @bottomAxis = d3.svg.axis()
      .orient("bottom")
      .scale(@x_bottom)
      .ticks(@n_contextticks)
      .tickSize(-@h_bottom, 0, 0)
            
    @bottom_xaxis = @svg.append("g")
      .attr("class", "context-xaxis")
      .attr("transform", "translate(" + @left_margin + "," + (@top_padding + @height) + ")")      
      .call(@bottomAxis)
    
    # Focus area and interaction on bottom
    @context_left = @bottom.append("svg:rect")
      .attr("class", "context-shaded")
      .attr("height", @h_bottom)
        
    @context_right = @bottom.append("svg:rect")
      .attr("class", "context-shaded")
      .attr("height", @h_bottom)
        
    # Draw everything (this runs fast and can be re-called for changes!)    
    @graph_zoom() 
  
  graph_zoom: =>
    # Adjust scales and zoom to enforce panning extent
    # FIXME: a little bit of stickiness on right with translate vector
    t = @zoom_graph.translate()
    ext = [@x_scale(@lcData.start), @width - @x_scale(@lcData.end)]

    d = @x_scale.domain()
    dt = d[1] - d[0]
    if d[0] < @lcData.start  
      d[0] = @lcData.start
      d[1] = d[0] + dt 
    if d[1] > @lcData.end
      d[1] = @lcData.end
      d[0] = d[1] - dt 
    @x_scale.domain(d)
  
    @zoom_graph
      .scale( (@lcData.end - @lcData.start) / (d[1] - d[0]) )
      .translate([t[0] - Math.max(0, ext[0]), t[1] - Math.max(0, ext[1])])
    
    # Adjust context area stuff
    @context_left
      .attr("width", @x_bottom(d[0]))
    @context_right
      .attr("x", @x_bottom(d[1]))
      .attr("width", @width - @x_bottom(d[1]) )
  
    # Adjust main area axes and gridlines
    @svg_xaxis.call(@xAxis)
    @svg_yaxis.call(@yAxis)
  
    # Draw dots!
    data = @lcData.data    
    @canvas.clearRect(0, 0, @width, @h_graph)
            
    i = -1
    n = data.length
    h = @h_graph
    @canvas.beginPath()    
    while ++i < n
      d = data[i]
      cx = @x_scale(d.x)
      cy = @y_scale(d.y)
      @canvas.moveTo(cx, cy)
      @canvas.arc(cx, cy, 2.5, 0, 2 * Math.PI)
    
    @canvas.fillStyle = "#FFFFFF"          
    @canvas.fill()
          
module.exports = Viewer

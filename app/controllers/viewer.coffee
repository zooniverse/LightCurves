Spine = require('spine')

LightcurveData = require 'models/lightcurveData'
LightcurveMeta = require 'models/lightcurveMeta'

class Viewer extends Spine.Controller
  
  elements:
    '#zoom': 'zoomBtn'
    
  events:
    # Why are these not working? Something nuts.
    'click #zoom a': 'zoom'
    'mouseenter #zoom a': -> $("#yZoom_help").show()
    'mouseleave #zoom a': -> $("#yZoom_help").delay(1600).fadeOut 1600
      
  constructor: ->
    super
    @el.attr("id", "graph")
    @self = this # For when we have a thin arrow but need to reference fatness

    # Copied variables from stylus, fix in future
    @left_margin = 50
    @top_padding = 5
    
    @width ?= 670
    @height ?= 450
    @h_graph ?= 400
    @h_bottom ?= 30
    @max_zoom ?= 10
    
    @h_to_context = @top_padding + @height - @h_bottom
          
    @n_xticks = 10
    @n_yticks = 6
    @n_contextticks = 7
      
    # Stuff for marking transits  
    @annotations ?= true
    @current_box = null
  
  teardown: -> 
    # TODO: Clean things up 

    
  render: =>    
    @html require('views/viewer')(@)          
  
  zoom: (ev) ->
    ev.preventDefault()
    alert "click"
    # do stuff
  
  # clicked in the context of canvas  
  plot_click: =>
    [x, y] = d3.mouse(@canvas)
    
    if @current_box
      
    else        
      
    
  plot_mousemove: =>
    return unless @current_box
    [x, y] = d3.mouse(@canvas)

    if @current_box
      
    else          
    
  loadData: (json, meta) =>
    if not json or json.length <= 0 
      alert(t('lightcurve.problem')) 
      return
    
    $(".spinner").remove()
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
      .attr("width", @width + @left_margin * 2)
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
      .on("click", @plot_click )
      .on("mousedown.drag", @plot_drag )
      .on("touchstart.drag", @plot_drag )
      .call(@zoom_graph)
      .node()
    @canvas_2d = @canvas.getContext("2d")        
  
    # Bottom line graph, axes, ticks, and labels
    @lcLine = d3.svg.line()
      .x( (d) -> @x_bottom(d.x) )
      .y( (d) -> @y_bottom(d.y) )
        
    @bottom = @svg.append("g")
      .attr("class", "context")
      .attr("transform", "translate(" + @left_margin + "," + @h_to_context + ")")
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
    drag_context = d3.behavior.drag()
      .origin(Object)
      .on("drag", @contextDrag)
    drag_leftdot = d3.behavior.drag()
      .origin(Object)
      .on("drag", @leftDotDrag)
    drag_rightdot = d3.behavior.drag()
      .origin(Object)
      .on("drag", @rightDotDrag)
      
    @context_drag = @bottom.append("svg:rect")
      .attr("class", "context-drag")
      .attr("height", @h_bottom)
#      .call(@zoom_graph) # Enable zoom actions on here too!            
      .call(drag_context)
    
    @context_left = @bottom.append("svg:rect")
      .attr("class", "context-shaded")
      .attr("height", @h_bottom)
    @context_leftDot = @bottom.append("svg:circle")
      .attr("id", "context-leftdot")
      .attr("class", "context-dragdot")
      .attr("cy", 0.5 * @h_bottom)
      .attr("r", 7)
      .call(drag_leftdot)
    
    @context_right = @bottom.append("svg:rect")
      .attr("class", "context-shaded")
      .attr("height", @h_bottom)
    @context_rightDot = @bottom.append("svg:circle")
      .attr("id", "context-rightdot")
      .attr("class", "context-dragdot")
      .attr("cy", 0.5 * @h_bottom)
      .attr("r", 7)
      .call(drag_rightdot)

    # Container for annotations
    @svg_annotations = @svg.append("g")
      .attr("class", "chart-annotations")
      .attr("transform", "translate(" + @left_margin + "," + @top_padding + ")")

    # Register global event fixers
    d3.select("body")      
      .on("mouseup.drag", @mouseup)
      .on("touchend.drag", @mouseup)
        
    @show_tooltips()
        
    # Draw everything (this runs fast and can be re-called for changes!)    
    @graph_zoom() 
  
  # When plot is dragged
  plot_drag: -> 
    d3.select("body").style("cursor", "move")
  
  # Drag context (pan) with boundaries
  contextDrag: (d) =>
    dom = @x_scale.domain()
    context_width = @x_bottom(dom[1] - dom[0])
    d.x = Math.max(0, Math.min(@width - context_width, d3.event.x))
    
    dom[0] = @x_bottom.invert(d.x)
    dom[1] = @x_bottom.invert(d.x + context_width)
    @x_scale.domain(dom)
    
    @graph_zoom()    

  # Drag left dot (zoom) with limit on right
  leftDotDrag: (d) =>
    dom = @x_scale.domain()
    minContextWidth = @width / @max_zoom    
    d.x = Math.max(0, Math.min(@x_bottom(dom[1]) - minContextWidth, d3.event.x))    
    dom[0] = @x_bottom.invert d.x
    @x_scale.domain dom
    
    @graph_zoom()

  # Drag right dot (zoom) with limit on left
  rightDotDrag: (d) =>
    dom = @x_scale.domain()
    minContextWidth = @width / @max_zoom
    d.x = Math.max(@x_bottom(dom[0]) + minContextWidth, Math.min(@width, d3.event.x))
    dom[1] = @x_bottom.invert d.x
    @x_scale.domain dom
    
    @graph_zoom()

  # When mouse is released     
  mouseup: ->
    d3.select("body").style("cursor", "auto")
  
  graph_zoom: =>
    # Make consistent scales and zoom to enforce panning extent
    # First, check if we panned out if bounds, if so fix it
    dom = @x_scale.domain()
    dt = dom[1] - dom[0]
    if dom[0] < @lcData.start
      dom[0] = @lcData.start
      dom[1] = dom[0] + dt 
    if dom[1] > @lcData.end
      dom[1] = @lcData.end
      dom[0] = dom[1] - dt 
    @x_scale.domain(dom)
  
    # Second, fix zoom translation vector for adjusted x-scale 
    # This can happen from above, or from drags without zooming 
    new_scale = (@lcData.end - @lcData.start) / (dom[1] - dom[0])
    @zoom_graph
      .scale( new_scale )
      .translate([ -@x_bottom(dom[0]) * new_scale , 0])
    
    # Adjust context area stuff, with data for drag handling
    l_px = @x_bottom(dom[0])
    r_px = @x_bottom(dom[1])
    
    @context_left
      .attr("width", Math.max(0, l_px) )
    @context_leftDot
      .attr("cx", l_px)
      .data([x: l_px, y: 0])      
    @context_drag
      .attr("x", l_px)
      .attr("width", r_px - l_px)
      .data([x: l_px, y: 0])      
    @context_right
      .attr("x", r_px)
      .attr("width", Math.max(0, @width - r_px) )      
    @context_rightDot
      .attr("cx", r_px)
      .data([x: r_px, y: 0])
  
    # Adjust main area axes and gridlines
    @svg_xaxis.call(@xAxis)
    @svg_yaxis.call(@yAxis)
  
    # Plot dots!
    # FIXME: may only want to draw viewport dots for even faster!
    data = @lcData.data    
    @canvas_2d.clearRect(0, 0, @width, @h_graph)
            
    i = -1
    n = data.length
    h = @h_graph
    @canvas_2d.beginPath()    
    while ++i < n
      d = data[i]
      cx = @x_scale(d.x)
      cy = @y_scale(d.y)
      @canvas_2d.moveTo(cx, cy)
      @canvas_2d.arc(cx, cy, 2.5, 0, 2 * Math.PI)
    
    @canvas_2d.fillStyle = "#FFFFFF"          
    @canvas_2d.fill()

  show_tooltips: ->
    $("#xZoom_help").show().delay(3200).fadeOut 1600
    $("#yZoom_help").show().delay(3200).fadeOut 1600
          
module.exports = Viewer

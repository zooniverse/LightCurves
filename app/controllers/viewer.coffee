Spine = require('spine')

Lightcurve = require 'models/lightcurve'

class Viewer extends Spine.Controller
  
  elements:
    '#zoom': 'zoomBtn'
    
  events:
    # Why are these not working? Something to do with d3, probably.
    'click #zoom a': 'zoomYAxis'
    'mouseenter #zoom a': => return unless @allow_zoom; $("#yZoom_help").show()
    'mouseleave #zoom a': -> $("#yZoom_help").delay(1600).fadeOut 1600
    
    'mouseenter .context': => return unless @allow_zoom; $("#xZoom_help").show()
    'mouseleave .context': -> $("#xZoom_help").delay(1600).fadeOut 1600
      
  constructor: ->
    super
    @el.attr("id", "graph")
    @containerSelector ?= ".lightcurve"
    
    # Default options, also can be set dynamically
    @allow_annotations ?= true
    @show_simulations ?= false
    @allow_zoom ?= true
    @dialog ?= null
    @addTransitCallback ?= null

    # Copied variables from stylus, fix in future
    @left_margin = 50
    @right_margin = 10
    @top_padding = 5
    @bottom_padding = 20
    
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
    @resize_half_width = 3

    @transits = []
    @current_box = null
    
  render: =>    
    @html require('views/viewer')(@)          
  
  teardown: -> 
    # TODO: Better job of clean things up 
    @canvas_2d?.clearRect(0, 0, @width, @h_graph)
    @svg?.empty()

  setZoomEnabled: (b) ->
    @allow_zoom = b
    
    # Functions called by behaviors    
    if @allow_zoom
      @zoom_graph_beh
        .on("zoom", @redraw)        
      @drag_leftdot_beh
        .on("drag", @leftDotDrag)
      @drag_context_beh
        .on("drag", @contextDrag)
      @drag_rightdot_beh
        .on("drag", @rightDotDrag)
        
      @context_drag.style("cursor": null) 
      @context_leftDot.style("cursor": null) 
      @context_rightDot.style("cursor": null)   
    else
      @zoom_graph_beh
        .on("zoom", null)        
      @drag_leftdot_beh
        .on("drag", null)
      @drag_context_beh
        .on("drag", null)
      @drag_rightdot_beh
        .on("drag", null)
        
      @context_drag.style("cursor": "auto") 
      @context_leftDot.style("cursor": "auto") 
      @context_rightDot.style("cursor": "auto") 
  
  zoomYAxis: (ev) ->
    ev.preventDefault()
    alert "click"
    # do stuff
    
  loadData: (lightcurve) =>    
    $(".spinner")?.remove()
    @lightcurve = lightcurve
    
    # Scale for focus area.
    @x_scale = d3.scale.linear() 
      .domain([@lightcurve.start, @lightcurve.end])
      .range([0, @width])    
    @y_scale = d3.scale.linear()
      .domain([@lightcurve.ymin, @lightcurve.ymax])
      .range([@h_graph, 0])
  
    # Scale for bottom area.
    @x_bottom = d3.scale.linear()
      .domain([@lightcurve.start, @lightcurve.end])
      .range([0, @width])
    @y_bottom = d3.scale.linear()
      .domain([@lightcurve.ymin, @lightcurve.ymax])
      .range([@h_bottom, 0])        
    
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

    @svg = d3.select(@containerSelector).select("#graph_svg")
      .attr("width", @width + @left_margin + @right_margin)
      .attr("height", @height + @top_padding + @bottom_padding)
      
    @svg_xaxis = @svg.append("g")
      .attr("class", "chart-xaxis")
      .attr("transform", "translate(" + @left_margin + "," + (@top_padding + @h_graph) + ")")
    
    @svg_yaxis = @svg.append("g")
      .attr("class", "chart-yaxis")
      .attr("transform", "translate(" + @left_margin + "," + @top_padding + ")")

    # Size canvas and position at right spot relative to SVG - done in CSS
    @canvas = d3.select(@containerSelector).select("#graph_canvas")   
      .attr("width", @width)
      .attr("height", @h_graph)
    .node()
    @canvas_2d = @canvas.getContext("2d")        
  
    # Bottom line graph, axes, ticks, and labels
    @lcLine = d3.svg.line()
      .x( (d) -> @x_bottom(d.x) )
      .y( (d) -> @y_bottom(d.y) )
        
    @bottom = @svg.append("g")
      .attr("class", "context")
      .attr("transform", "translate(" + @left_margin + "," + @h_to_context + ")")
    @bottom.append("svg:path").attr("d", @lcLine(@lightcurve.data))
    
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
    @context_drag = @bottom.append("svg:rect")
      .attr("class", "context-drag")
      .attr("height", @h_bottom)
    
    @context_left = @bottom.append("svg:rect")
      .attr("class", "context-shaded")
      .attr("height", @h_bottom)
    @context_leftDot = @bottom.append("svg:circle")
      .attr("id", "context-leftdot")
      .attr("class", "context-dragdot")
      .attr("cy", 0.5 * @h_bottom)
      .attr("r", 7)
    
    @context_right = @bottom.append("svg:rect")
      .attr("class", "context-shaded")
      .attr("height", @h_bottom)
    @context_rightDot = @bottom.append("svg:circle")
      .attr("id", "context-rightdot")
      .attr("class", "context-dragdot")
      .attr("cy", 0.5 * @h_bottom)
      .attr("r", 7)

    # Container for annotations
    @svg_annotations = @svg.append("g")
      .attr("class", "chart-annotations")
      .attr("transform", "translate(" + @left_margin + "," + @top_padding + ")")

    # Defined behaviors
    @zoom_graph_beh = d3.behavior.zoom()
      .x(@x_scale)
      .scaleExtent([1, @max_zoom])
      
    @drag_context_beh = d3.behavior.drag().origin(Object)
    @drag_leftdot_beh = d3.behavior.drag().origin(Object)    
    @drag_rightdot_beh = d3.behavior.drag().origin(Object)
    
    @drag_transit = d3.behavior.drag().origin((d) => x: @x_scale(d.x), y: @y_scale(d.y))
    # Null is actually better than an explicit origin accessor, to preserve cursor consistency
    @resize_transit = d3.behavior.drag().origin(null)
    @resize_transit_ew = d3.behavior.drag().origin(null)
    @resize_transit_ns = d3.behavior.drag().origin(null)

    @drag_transit
      .on("drag", @transitDrag)
    @resize_transit
      .on("drag", @transitResize)
    @resize_transit_ew
      .on("drag", @transitResizeEW)
    @resize_transit_ns
      .on("drag", @transitResizeNS)

    # What we do with the behaviors    
    @svg
      .call(@zoom_graph_beh)
      .on("click", @plot_click )
      .on("mousemove", @plot_mousemove )
      .on("mousedown.drag", @plot_drag )
      .on("touchstart.drag", @plot_drag )
      
    @context_drag
      .call(@drag_context_beh)
    @context_leftDot
      .call(@drag_leftdot_beh)
    @context_rightDot
      .call(@drag_rightdot_beh)
    
    # Global event detectors
    d3.select("body")      
      .on("mouseup.drag", @mouseup)
      .on("touchend.drag", @mouseup)      


    @setZoomEnabled @allow_zoom        
    @show_tooltips() if @allow_zoom
        
    # Call draw function once 
    # it runs fast and can be called for changes/animations
    @redraw()
    
  # When plot is dragged
  plot_drag: -> 
    return unless @allow_zoom
    d3.select("body").style("cursor", "move")
  
  # When mouse is released     
  mouseup: ->
    d3.select("body").style("cursor", "auto")
  
  plot_click: =>
    return unless @allow_annotations
    # calculate coords relative to canvas  
    [x, y] = d3.mouse(@canvas)

    if @current_box 
      # Make box permanent
      d3.select("body").style("cursor", "auto")      
      # TODO: cancel if box is too small (square size)
      
      d = @current_box.datum()
      d.dx = Math.abs(@x_scale.invert(x) - d.x)
      d.dy = Math.abs(@y_scale.invert(y) - d.y)
      d.num = @transits.length
      
      @current_box
        .attr("class", "transit")

      # Center dot  
      @current_box
      .append("svg:circle")
        .attr("class", "transit-center")
        .attr("r", 2)
      # Top circle and label
      @current_box
      .append("svg:circle")
        .attr("class", "transit-label")
        .attr("r", 10)        
      @current_box
      .append("svg:text")
        .attr("class", "transit-text")
        .attr("text-anchor", "middle")
        .text((d) -> d.num)
      # Drag and resize handles
      @current_box
        .call(@drag_transit)
        .on("click", @transitZoom)
              
      @current_box
      .append("svg:rect") # Top handle
        .attr("class", "n-resize")
        .attr("height", @resize_half_width * 2)
        .call(@resize_transit_ns)
      @current_box
      .append("svg:rect") # Bottom handle
        .attr("class", "s-resize")
        .attr("height", @resize_half_width * 2)
        .call(@resize_transit_ns)
      @current_box
      .append("svg:rect") # Right handle
        .attr("class", "e-resize")
        .attr("width", @resize_half_width * 2)
        .call(@resize_transit_ew)
      @current_box
      .append("svg:rect") # Left handle
        .attr("class", "w-resize")
        .attr("width", @resize_half_width * 2)
        .call(@resize_transit_ew)

      @current_box
      .append("svg:rect") # Top right handle
        .attr("class", "ne-resize")
        .attr("width", @resize_half_width * 2)
        .attr("height", @resize_half_width * 2)
        .call(@resize_transit)
      @current_box
      .append("svg:rect") # Bot right handle
        .attr("class", "se-resize")
        .attr("width", @resize_half_width * 2)
        .attr("height", @resize_half_width * 2)
        .call(@resize_transit)
      @current_box
      .append("svg:rect") # Top right handle
        .attr("class", "sw-resize")
        .attr("width", @resize_half_width * 2)
        .attr("height", @resize_half_width * 2)
        .call(@resize_transit)
      @current_box
      .append("svg:rect") # Top right handle
        .attr("class", "nw-resize")
        .attr("width", @resize_half_width * 2)
        .attr("height", @resize_half_width * 2)
        .call(@resize_transit)

      @transits.push @current_box
      @redraw_transits @current_box
      @current_box = null
      @addTransitCallback?()
    else
      d3.select("body").style("cursor", "crosshair")
      @current_box = @svg_annotations
        .append("svg:g")
        .attr("class", "transit-temp")
        .attr("transform", "translate(" + x + "," + y + ")")
        .datum
          x: @x_scale.invert(x)
          y: @y_scale.invert(y)
          dx: 0
          dy: 0

      @current_box
      .append("svg:rect")
        .attr("class", "transit-rect")
    
  plot_mousemove: =>
    return unless @current_box
    [x, y] = d3.mouse(@canvas)

    # Cancel the box and fix the cursor        
    if x < 0 or x > @width or y < 0 or y > @h_graph
      d3.select("body").style("cursor", "auto")
      @current_box.remove()
      @current_box = null

    if @current_box
      d = @current_box.datum()      
      d.dx = Math.abs(@x_scale.invert(x) - d.x)
      d.dy = Math.abs(@y_scale.invert(y) - d.y)
      
      @redraw_transits @current_box

  redraw_transits: (selection) =>
    selection ?= @svg_annotations.selectAll("g")
    
    xs = @x_scale
    ys = @y_scale
    adj = @resize_half_width
    
    selection.each (d) ->
      half_w = xs(d.dx) - xs(0)
      half_h = ys(0) - ys(d.dy) # Because y-scale is reversed
          
      box = d3.select(this)
      
      box.select(".transit-rect")
        .attr("x", -half_w)
        .attr("y", -half_h)
        .attr("width", 2 * half_w)
        .attr("height", 2 * half_h)        
      box.select("circle.transit-label")
        .attr("cx", half_w)
      box.select("text.transit-text")
        .attr("x", half_w)
        
      box.select("rect.n-resize")
        .attr("x", -half_w)
        .attr("y", -half_h - adj)
        .attr("width", 2 * half_w)
      box.select("rect.s-resize")
        .attr("x", -half_w)
        .attr("y", half_h - adj)
        .attr("width", 2 * half_w)
      box.select("rect.e-resize")
        .attr("x", half_w - adj)
        .attr("y", -half_h)
        .attr("height", 2 * half_h)
      box.select("rect.w-resize")
        .attr("x", -half_w - adj)
        .attr("y", -half_h)
        .attr("height", 2 * half_h)

      box.select("rect.ne-resize")
        .attr("x", half_w - adj)
        .attr("y", -half_h - adj)
      box.select("rect.se-resize")
        .attr("x", half_w - adj)
        .attr("y", half_h - adj)
      box.select("rect.sw-resize")
        .attr("x", -half_w - adj)
        .attr("y", half_h - adj)
      box.select("rect.nw-resize")
        .attr("x", -half_w - adj)
        .attr("y", -half_h - adj)

  animateZoom: (target_dom) =>
    current_dom = @x_scale.domain()
    [target_dom, scale] = @getZoomPanFix target_dom
    return if current_dom[0] == target_dom[0] and current_dom[1] == target_dom[1]
        
    # FIXME: disable zoom and other events during this
    rd = @redraw
    @svg.transition()
      .duration(1000)
      .tween "zoom", -> 
          interp = d3.interpolate(current_dom, target_dom)
          (t) -> rd interp(t)
  
  transitZoom: (d) =>
    # Stop a second box from being drawn
    d3.event.stopPropagation()

    # Arbitrary rule: scale transit to 1/7 of horz area

    box_w = 6 * d.dx
    target_dom = [d.x - d.dx - box_w, d.x + d.dx + box_w]
    @animateZoom target_dom
    
  transitDrag: (d) =>
    [x, y] = [d3.event.x, d3.event.y]
    # Don't allow transit to be dragged outside canvas
    x = Math.max(0, Math.min(x, @width))
    y = Math.max(0, Math.min(y, @h_graph))
    
    d.x = @x_scale.invert x
    d.y = @y_scale.invert y
    @transits[d.num].attr("transform", "translate(" + x + "," + y + ")")
    
  transitResize: (d) =>
    d.dx = Math.abs(@x_scale.invert(d3.event.x) - @x_scale.invert(0))
    d.dy = Math.abs(@y_scale.invert(d3.event.y) - @y_scale.invert(0))
    @redraw_transits @transits[d.num]

  transitResizeEW: (d) =>
    d.dx = Math.abs(@x_scale.invert(d3.event.x) - @x_scale.invert(0))
    @redraw_transits @transits[d.num]
    
  transitResizeNS: (d) =>
    d.dy = Math.abs(@y_scale.invert(d3.event.y) - @y_scale.invert(0))
    @redraw_transits @transits[d.num]
      
  # Drag context (pan) with boundaries
  contextDrag: (d) =>
    dom = @x_scale.domain()
    context_width = @x_bottom(dom[1] - dom[0])
    d.x = Math.max(0, Math.min(@width - context_width, d3.event.x))
    
    dom[0] = @x_bottom.invert(d.x)
    dom[1] = @x_bottom.invert(d.x + context_width)
    @x_scale.domain(dom)
    
    requestAnimFrame => @redraw()    

  # Drag left dot (zoom) with limit on right
  leftDotDrag: (d) =>
    dom = @x_scale.domain()
    minContextWidth = @width / @max_zoom    
    d.x = Math.max(0, Math.min(@x_bottom(dom[1]) - minContextWidth, d3.event.x))    
    dom[0] = @x_bottom.invert d.x
    @x_scale.domain dom
    
    requestAnimFrame => @redraw()

  # Drag right dot (zoom) with limit on left
  rightDotDrag: (d) =>
    dom = @x_scale.domain()
    minContextWidth = @width / @max_zoom
    d.x = Math.max(@x_bottom(dom[0]) + minContextWidth, Math.min(@width, d3.event.x))
    dom[1] = @x_bottom.invert d.x
    @x_scale.domain dom
    
    requestAnimFrame => @redraw()

  getZoomPanFix: (dom) ->
    # Make consistent scales and zoom to enforce panning extent
    
    # Check if we would pan out if bounds, if so fix it
    dt = dom[1] - dom[0]
    if dom[0] < @lightcurve.start
      dom[0] = @lightcurve.start
      dom[1] = dom[0] + dt 
    if dom[1] > @lightcurve.end
      dom[1] = @lightcurve.end
      dom[0] = dom[1] - dt
    if dom[0] < @lightcurve.start
      dom[0] = @lightcurve.start
  
    # Compute new zoom x-scale 
    # This can happen from above, or from drags without zooming 
    extent = @lightcurve.end - @lightcurve.start
    new_scale = extent / (dom[1] - dom[0])    
    
    # Don't allow zooming beyond max zoom
    if new_scale > @max_zoom
      new_scale = @max_zoom
      midpt = 0.5 * (dom[1] + dom[0])
      ext_scale = (extent / new_scale) / 2
      dom = [ midpt - ext_scale, midpt + ext_scale ]
    
    [dom, new_scale]

  redraw: (target_dom) =>
    target_dom ?= @x_scale.domain()
    [dom, new_scale] = @getZoomPanFix target_dom

    # Set domain and fix zoom translation vector accordingly
    @x_scale.domain(dom)
    @zoom_graph_beh
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
    
    # Adjust transit annotations
    @svg_annotations.selectAll("g")
      .attr("transform", (d) => "translate(" + @x_scale(d.x) + "," + @y_scale(d.y) + ")")
    @redraw_transits()
  
    # Plot dots!
    # FIXME: may only want to draw viewport dots for even faster!
    # Premature optimization right here:
    xs = @x_scale
    ys = @y_scale
    canvas = @canvas_2d
    data = @lightcurve.data
        
    canvas.clearRect(0, 0, @width, @h_graph)
    
    h = @h_graph
    # Draw error bars
    i = -1
    n = data.length
    canvas.beginPath()
    while ++i < n
      d = data[i]
      x = xs(d.x)
      bot = ys(d.y - d.dy)
      top = ys(d.y + d.dy)
      canvas.moveTo(x, bot)
      canvas.lineTo(x, top)
    canvas.lineWidth = 1
    canvas.strokeStyle = "rgba(255,255,255,0.1)"
    canvas.stroke()
    
    # Draw dots
    canvas.lineWidth = 0
    if @show_simulations then @drawDotsSimul() else @drawDotsNormal()

  # Faster when we don't have to draw transits
  drawDotsNormal: ->
    xs = @x_scale
    ys = @y_scale
    canvas = @canvas_2d
    data = @lightcurve.data
    twopi = 2 * Math.PI
    
    i = -1
    n = data.length
    canvas.beginPath()    
    while ++i < n
      d = data[i]
      cx = xs(d.x)
      cy = ys(d.y)  
      canvas.moveTo(cx, cy)
      canvas.arc(cx, cy, 2.5, 0, twopi)      
    canvas.fillStyle = "#FFFFFF"
    canvas.fill()
    
  drawDotsSimul: ->
    xs = @x_scale
    ys = @y_scale
    canvas = @canvas_2d
    data = @lightcurve.data
    twopi = 2 * Math.PI
    
    i = -1
    n = data.length
    was_transit = no
    canvas.beginPath()    
    while ++i < n
      d = data[i]
      cx = xs(d.x)
      cy = ys(d.y)        
      # Close not transit with white
      if d.tr > 0 and !was_transit
        was_transit = yes
        canvas.fillStyle = "#FFFFFF"          
        canvas.fill()
        canvas.beginPath()
      # Close transit with red
      if was_transit and d.tr == 0
        was_transit = no
        canvas.fillStyle = "#BF4040"
        canvas.fill()
        canvas.beginPath()        
      canvas.moveTo(cx, cy)
      canvas.arc(cx, cy, 2.5, 0, twopi)      
    canvas.fillStyle = "#FFFFFF"
    canvas.fill()

  show_tooltips: ->
    $("#xZoom_help").show().delay(3200).fadeOut 1600
    $("#yZoom_help").show().delay(3200).fadeOut 1600
          
module.exports = Viewer

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

    @width = 670
    @height = 440
    @h_graph = 400
    @h_bottom = 30
      
    @max_zoom = 10
    
    @n_xticks = 10
    @n_yticks = 10
    
    # Copied variables from stylus, fix in future
    @left_margin = 50
    @top_padding = 5
      
    # Add spinner in future  
    @loading = false
  
  teardown: -> # Clean things up 
    
  render: =>    
    @html require('views/lightcurve')(@)          
  
  loadData: (json, meta) =>
    alert(t('lightcurve.problem')) if not json or json.length <= 0
    
    @lcData = new LightcurveData(data: json)
    
    @x_graph = d3.scale.linear() 
      .domain([@lcData.start, @lcData.end])
      .range([0, @width])
    
    @y_graph = d3.scale.linear()
      .domain([@lcData.ymin, @lcData.ymax])
      .range([@h_graph, 0])
  
    @x_bottom = d3.scale.linear()
      .domain([@lcData.start, @lcData.end])
      .range([0, @width])
    @y_bottom = d3.scale.linear()
      .domain([@lcData.ymin, @lcData.ymax])
      .range([0, @h_bottom])
      
    @xAxis = d3.svg.axis()
      .orient("bottom")
      .scale(@x_graph)
      .ticks(@n_xticks)
      .tickSize(-@h_graph, 0, 0)
    
    @yAxis = d3.svg.axis()
      .orient("left")
      .scale(@y_graph)
      .ticks(@n_yticks)
      .tickSize(-@width, 0, 0)
    
    @zoom_graph = d3.behavior.zoom()
      .x(@x_graph)
      .scaleExtent([1, @max_zoom])
      .on("zoom", @graph_zoom)
      
    @zoom_bottom = d3.behavior.zoom()
      .x(@x_bottom)
      .scaleExtent([1, @max_zoom])   
      .on("zoom", @bottom_zoom)
    
    @svg = d3.select("#graph_svg")
    .attr("width", @width + @left_margin)
    .attr("height", @height + @top_padding)

    # x (vertical) ticks and labels
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
    
    @graph_zoom() 
    
  zoom: (ev) ->
    ev.preventDefault()
    alert "click"
    # do stuff
  
  graph_zoom: =>
    # Adjust scales if went beyond ends
    
  
    # Adjust axes and gridlines
    @svg_xaxis.call(@xAxis)
    @svg_yaxis.call(@yAxis)
  
    data = @lcData.data    
    @canvas.clearRect(0, 0, @width, @h_graph)
            
    i = -1
    n = data.length
    h = @h_graph
    @canvas.beginPath()    
    while ++i < n
      d = data[i]
      cx = @x_graph(d.x)
      cy = @y_graph(d.y)
      @canvas.moveTo(cx, cy)
      @canvas.arc(cx, cy, 2.5, 0, 2 * Math.PI)
    
    @canvas.fillStyle = "#FFFFFF"          
    @canvas.fill()
    
  bottom_zoom: =>
    alert "bottom zoom"

          
module.exports = Viewer
